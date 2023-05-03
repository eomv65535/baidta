class Themes::BaidataTheme::TpvController < CamaleonCms::Apps::ThemesFrontController
    require 'timeout'

    def payok
        if(params[:b]=="inscr")
            elinscrito = current_site.inscritos.where(id: params[:c]).first 
            curso = current_site.the_posts("cursos").find(elinscrito.idslug)
            elinscrito.estatus = 'activo'
            elinscrito.save! 
            
            cama_send_email(elinscrito.email, curso.get_field("asunto-email").translate(I18n.locale.to_s.upcase),
            {content: curso.get_field("contenido-correo").translate(I18n.locale.to_s.upcase)})  
            redirect_to cama_okinscr_path
        end            
    end
    def okinscr
    end    
    def nokinscr
    end    
    def paynok
        if(params[:b]=="inscr")
            elinscrito = current_site.inscritos.where(id: params[:c]).first 
            
            elinscrito.estatus = 'pendiente'
            elinscrito.save!
            flash[:error] = "Pago no completado, intente nuevamente!"
            redirect_to '/plugins/custom_registro/pagar/'+params[:c]          
        end            
    end
      
end
