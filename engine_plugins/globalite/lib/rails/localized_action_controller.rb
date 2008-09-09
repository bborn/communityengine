module ActionController
  class Base
    
    # Error messages modified in lang file
    @@resources_path_names.update ({ 
      :new => :resources_path_new.l('new') , 
      :edit => :resources_path_edit.l('edit')
    })
    
    # Reloads the localization
    def self.relocalize
      @@resources_path_names.update ({ 
        :new => :resources_path_new.l('new') , 
        :edit => :resources_path_edit.l('edit')
      })
    end
  end
end
