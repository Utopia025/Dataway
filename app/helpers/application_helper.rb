module ApplicationHelper
	def full_title(page_title)
		base_title = 'Dataway'
		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end
	
	# Include Devise resource control in non-Devise controllers
	def resource_name
    		:user
  	end

  	def resource
		@resource ||= User.new
	end

    	def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
	end

end
