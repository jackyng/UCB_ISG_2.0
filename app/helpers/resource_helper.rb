module ResourceHelper
	def find_resource_param(resource_id, key)
    @resource = Resource.find(resource_id)
    if (key == 'name')
        return @resource.name
    else
        return @resource.url
    end
  end
end
