module Themes::BaidataTheme::MainHelper
  def self.included(klass)
    # klass.helper_method [:my_helper_method] rescue "" # here your methods accessible from views
     klass.helper_method [:baidata_dibuja_idiomas] rescue "" # here your methods accessible from views
  end

  def baidata_theme_settings(theme)
    # callback to save custom values of fields added in my_theme/views/admin/settings.html.erb
  end

  # callback called after theme installed
  def baidata_theme_on_install_theme(theme)
    # # Sample Custom Field
    # unless theme.get_field_groups.where(slug: "fields").any?
    #   group = theme.add_field_group({name: "Main Settings", slug: "fields", description: ""})
    #   group.add_field({"name"=>"Background color", "slug"=>"bg_color"},{field_key: "colorpicker"})
    #   group.add_field({"name"=>"Links color", "slug"=>"links_color"},{field_key: "colorpicker"})
    #   group.add_field({"name"=>"Background image", "slug"=>"bg"},{field_key: "image"})
    # end

    # # Sample Meta Value
    # theme.set_meta("installed_at", Time.current.to_s) # save a custom value
  end

  # callback executed after theme uninstalled
  def baidata_theme_on_uninstall_theme(theme)
  end

  def baidata_dibuja_idiomas
    lan = current_site.get_languages
    current_page = true    
    res = "<a class='dropdown-toggle' data-toggle='dropdown'>#{I18n.locale.to_s.upcase} <span class='caret'></span></a><ul class='dropdown-menu'>"    
    lan.each do |lang|
      if I18n.locale.to_s != lang.to_s        
        res +=  "<li> <a href='#{cama_url_to_fixed("url_for", {locale: lang})}'>#{lang}</a> </li>"
      end
    end
    res += "</ul>"   
  end  
    
  def rangos(args)
      args[:fields][:rangos] = {
          key: 'rangos',
          label: 'Rangos',
          render: theme_view('custom_field/rangos'),
          options: {
              required: true,
              
          }
      }
  end

  def listado_empresas(args)
      args[:fields][:la_empresa] = {
          key: 'la_empresa',
          label: 'Empresa',
          render: theme_view('custom_field/empresas_select'),
          options: {
              required: true,
              multiple: true,
          }
      }
  end
  
  def options_empresas    
    return current_site.the_posts("empresas").decorate
  end  
end
