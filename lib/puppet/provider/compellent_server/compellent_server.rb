require 'puppet/provider/compellent'
require 'puppet/lib/ResponseParser'

Puppet::Type.type(:compellent_server).provide(:compellent_server, :parent => Puppet::Provider::Compellent) do
  @doc = "Manage Compellent Server creation and deletion."
  def create_servercommandline
    command = "server create -name '#{@resource[:name]}' -WWN '#{@resource[:wwn]}'"
	
	server_serverfolder = @resource[:serverfolder]
	server_serverfolder = server_serverfolder.strip
    if server_serverfolder.length > 0
      command = command + " -folder '#{server_serverfolder}'"
    end
	
	server_notes = @resource[:notes]
	server_notes = server_notes.strip
    if server_notes.length > 0
      command = command + " -notes '#{server_notes}'"
    end
	
	server_operatingsystem = @resource[:operatingsystem] 
	server_operatingsystem = server_operatingsystem.strip
    if server_operatingsystem.length > 0
	command = command + " -os '#{server_operatingsystem}'"
    end
    return command
  end

  def showserver_commandline
    command = "server show -name '#{@resource[:name]}'"
    server_serverfolder = @resource[:serverfolder]
    server_serverfolder = server_serverfolder.strip
    if server_serverfolder.length > 0 
      command = command + " -folder '#{@resource[:serverfolder]}'"
    end
    return command
  end
  
  def getLogPath(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    p = Pathname.new(temp_path)
    while $i < $num  do
      p = Pathname.new(temp_path)
      temp_path = p.dirname
      $i +=1
    end
    temp_path = temp_path.join('logs')
    Puppet.debug("Log Path #{temp_path}")
    return  temp_path
  end
  
  def getUniqueRefId()
    randNo = Random.rand(100000)
    pid = Process.pid
    return "#{randNo}_PID_#{pid}"
  end
  
  def get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    p = Pathname.new(temp_path)
    while $i < $num  do
      p = Pathname.new(temp_path)
      temp_path = p.dirname
      $i +=1
    end
    temp_path = temp_path.join('lib/CompCU-6.3.jar')
    Puppet.debug("Path #{temp_path}")
    return  temp_path
  end

  def create
    puts "Inside Create Method."
    server_name = @resource[:name]
    Puppet.debug("Resource name #{server_name}")
    servercli = create_servercommandline
    puts "Server CLI"
    puts servercli
    
    Puppet.debug("Creating server with name '#{server_name}'")

    libpath = get_path(2)
	serverCreateExitCodeXML = "#{getLogPath(2)}/serverCreateExitCode_#{getUniqueRefId}.xml"
	
    servercreatecommand = "java -jar -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile #{serverCreateExitCodeXML} -c \"#{servercli}\""
    Puppet.debug(servercreatecommand)
    response =  system (servercreatecommand)

    parserobj=ResponseParser.new('_')
    parserobj.parse_exitcode(serverCreateExitCodeXML)
    hash= parserobj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.info("Server #{server_name} created successful..")
      else
      Puppet.info("Failed to create Server #{server_name}")
      raise Puppet::Error, "#{hash['Error']}"
    end

  end

  def destroy
    server_name = @resource[:name]
    Puppet.debug("Inside Destroy method")
    Puppet.debug("Destroying server #{server_name}")

    libpath = get_path(2)
	serverDestroyExitCodeXML = "#{getLogPath(2)}/serverDestroyExitCode_#{getUniqueRefId}.xml"
    serverdestroycommand = "java -jar -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile #{serverDestroyExitCodeXML} -c \"server delete -name #{server_name}\""
    system(serverdestroycommand)

    parserobj=ResponseParser.new('_')
    parserobj.parse_exitcode(serverDestroyExitCodeXML)
    hash= parserobj.return_response
    if "#{hash['Success']}".to_str() == "TRUE"
      Puppet.info("Server #{server_name} deleted successful..")
      else
      Puppet.info("Failed to delete Server #{server_name}")
      raise Puppet::Error, "#{hash['Error']}"
    end

  end

  def exists?
    Puppet.debug("Puppet::Provider::Compellenet_server: checking existance of compellent server #{@resource[:name]}")
    Puppet.debug(" resource[:ensure]  ==  #{@resource[:ensure]}")
	libpath = get_path(2)
	serverShowCLI = showserver_commandline
	serverShowExitCodeXML = "#{getLogPath(2)}/serverShowExitCode_#{getUniqueRefId}.xml"
	serverShowResponseXML = "#{getLogPath(2)}/serverShowResponse_#{getUniqueRefId}.xml"
	serverShowCommand = "java -jar #{libpath} -host #{@resource[:host]} -user #{@resource[:user]} -password #{@resource[:password]} -xmloutputfile #{serverShowExitCodeXML} -c \"#{serverShowCLI} -xml #{serverShowResponseXML}\""
    system(serverShowCommand)
    
    parserObj=ResponseParser.new('_')
    parserObj.parse_discovery(serverShowExitCodeXML,serverShowResponseXML,0)
    hash= parserObj.return_response
    serverName = "#{hash['server_Name']}"
    Puppet.debug("Server Name - #{serverName}")
		
    ##if("#{@resource[:ensure]}" == "absent")
    ##  @property_hash[:ensure] = :present
    ##else
    ##  @property_hash[:ensure] = :absent
    ##end
    Puppet.debug("Value = #{@property_hash[:ensure]}")
    #@property_hash[:ensure] == :present
	
      if  "#{serverName}" == ""
      Puppet.info("Puppet::Server does not exist")
      false
    else
      #Server exist, can delete!
      #@property_hash[:ensure] = :absent
      true
    end
	
  end

end



