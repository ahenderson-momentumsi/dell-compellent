Puppet::Type.newtype(:compellent_volume) do 
  @doc = "Manage Compellent Volume creation, modification and deletion."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The volume name. Valid characters are a-z, 1-9 & underscore."
    isnamevar
  end
  
  newparam(:size) do
    desc "The initial volume size. Valid format is 1-9(kmgt)."
    defaultto "1g"
    validate do |value|
      unless value =~ /^\d+[kmgt]$/
         raise ArgumentError, "%s is not a valid initial volume size." % value
      end
    end
  end
  
  newparam(:boot, :boolean => true) do
    desc "The aggregate this volume should be created in." 
    desc "Should volume size auto-increment be enabled? Defaults to `:true`."
    newvalues(:true, :false)
    defaultto :true
  end
  
  newparam(:volumefolder) do
    desc "The folder this volume should be created in." 
  end
 newparam(:purge) do
	desc "Force option for create volume."
  end
  
  newparam(:notes) do
    desc "The language code this volume should use."
  end
  
  newparam(:replayprofile) do
    desc "The space reservation mode."
  end
  
  newparam(:storageprofile) do
    desc "The space reservation mode."
  end
  
  newparam(:user) do
    desc "User for Compellent."
  end
  
  newparam(:password) do
    desc "Password for Compellent."
  end
  newparam(:host) do
    desc "IP address of Compellent."
  end
  
end
