require 'puppet/util/network_device/compellent'
require 'puppet/util/network_device/transport_compellent'
require 'rexml/document'
require 'puppet/lib/ResponseParser'

require 'json'
require 'xmlsimple'


include REXML

class Puppet::Util::NetworkDevice::Compellent::Facts

  attr_reader :transport
  attr_accessor :facts,:seperator
  def initialize(transport)
    Puppet.debug("In facts initialize")
    @facts = Hash.new
    @seperator="_"
    @transport = transport
  end

   def get_unique_refid()
    randno = Random.rand(100000)
    pid = Process.pid
    return "#{randno}_PID_#{pid}"
  end

  def get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
      path = Pathname.new(temp_path)
      temp_path = path.dirname
      $i +=1
    end
    temp_path = temp_path.join('lib/CompCU-6.3.jar')
    Puppet.debug("Path #{temp_path}")
    return  temp_path
  end

  def get_log_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
      path = Pathname.new(temp_path)
      temp_path = path.dirname
      $i +=1
    end
    temp_path = temp_path.join('logs')
    Puppet.debug("Log Path #{temp_path}")
    return  temp_path
  end

  def get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH #{temp_path}")
    $i = 0
    $num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
      path = Pathname.new(temp_path)
      temp_path = path.dirname
      $i +=1
    end
    temp_path = temp_path.join('lib/CompCU-6.3.jar')
    Puppet.debug("Final Lib Path #{temp_path}")
    return temp_path
  end

  def retrieve
    libpath = get_path(3)
    Puppet.debug("In facts retrieve")
    Puppet.debug("IP Address is #{@transport.host} Username is #{@transport.user} Password is #{@transport.password}")

    system_respxml = "#{get_log_path(3)}/systemResp_#{get_unique_refid}.xml"
    system_exitcodexml = "#{get_log_path(3)}/systemExitCode_#{get_unique_refid}.xml"
    ctrl_respxml = "#{get_log_path(3)}/ctrlResp_#{get_unique_refid}.xml"
    ctrl_exitcodexml = "#{get_log_path(3)}/ctrlExitCode_#{get_unique_refid}.xml"
    diskfolder_respxml = "#{get_log_path(3)}/diskfolderResp_#{get_unique_refid}.xml"
    diskfolder_exitcodexml = "#{get_log_path(3)}/diskfolderExitCode_#{get_unique_refid}.xml"
    volume_respxml = "#{get_log_path(3)}/volumeResp_#{get_unique_refid}.xml"
    volume_exitcodexml = "#{get_log_path(3)}/volumeExitCode_#{get_unique_refid}.xml"
    server_respxml = "#{get_log_path(3)}/serverResp_#{get_unique_refid}.xml"
    server_exitcodexml = "#{get_log_path(3)}/serverExitCode_#{get_unique_refid}.xml"
    replayprofile_respxml = "#{get_log_path(3)}/replayprofileResp_#{get_unique_refid}.xml"
    replayprofile_exitcodexml = "#{get_log_path(3)}/replayprofileExitCode_#{get_unique_refid}.xml"
    storageprofile_respxml = "#{get_log_path(3)}/storageprofileResp_#{get_unique_refid}.xml"
    storageprofile_exitcodexml = "#{get_log_path(3)}/storageprofileExitCode_#{get_unique_refid}.xml"
    
    
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{system_exitcodexml} -c \"system show -xml #{system_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{ctrl_exitcodexml} -c \"controller show -xml #{ctrl_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{diskfolder_exitcodexml} -c \"diskfolder show -xml #{diskfolder_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{volume_exitcodexml} -c \"volume show -xml #{volume_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{server_exitcodexml} -c \"server show -xml #{server_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{replayprofile_exitcodexml} -c \"replayprofile show -xml #{replayprofile_respxml}\" ")
    response = system("java -jar #{libpath} -host #{@transport.host} -user #{@transport.user} -password #{@transport.password} -xmloutputfile #{storageprofile_exitcodexml} -c \"storageprofile show -xml #{storageprofile_respxml}\" ")

    Puppet.debug("Creating Parser Object")
    parser_obj=ResponseParser.new('_')
    parser_obj.parse_discovery(system_exitcodexml,system_respxml,0)
    parser_obj.parse_discovery(ctrl_exitcodexml,ctrl_respxml,1)
    parser_obj.parse_diskfolder_xml(diskfolder_exitcodexml,diskfolder_respxml)
    @facts =  parser_obj.return_response
    self.facts["system_data"]=JSON.pretty_generate(XmlSimple.xml_in(system_respxml))
    self.facts["diskfolder_data"]=JSON.pretty_generate(XmlSimple.xml_in(diskfolder_respxml))
    self.facts["controller_data"]=JSON.pretty_generate(XmlSimple.xml_in(ctrl_respxml))
    self.facts["volume_data"]=JSON.pretty_generate(XmlSimple.xml_in(volume_respxml))
    self.facts["server_data"]=JSON.pretty_generate(XmlSimple.xml_in(server_respxml))
    self.facts["replayprofile_data"]=JSON.pretty_generate(XmlSimple.xml_in(replayprofile_respxml))
    self.facts["storageprofile_data"]=JSON.pretty_generate(XmlSimple.xml_in(storageprofile_respxml))

    
    @facts
  end

end

