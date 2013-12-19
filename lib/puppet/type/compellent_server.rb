Puppet::Type.newtype(:compellent_server) do 
  @doc = "Manage Compellent Server creation and deletion."
  
  apply_to_device
  
  ensurable


 newparam(:name) do
    desc "The volume name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
  end 
  
  newparam(:operatingsystem) do
    desc "The Server operatingSystem. Valid format is 1-9(kmgt)."
  end
  
  newparam(:notes) do
    desc "The description for the server."
  end
  
  newparam(:serverfolder) do
    desc "The server folder."
  end
  
 newparam(:wwn) do
    desc "The WWN to map Server."
    validate do |value|
      unless value =~ /^\w+$/
        raise ArgumentError, "%s is not a valid WWN number." % value
      end
    end
 end
  
  newparam(:user) do
    desc "User for compellent."
  end
  
  newparam(:password) do
    desc "Password for compellent."    
  end
  
  newparam(:host) do
    desc "IP address for compellent." 
  end
   
end

