class Themes::BaidataTheme::NewloginController < CamaleonCms::Apps::ThemesFrontController  

  require 'createsend'
  require 'URLcrypt'
  include ActionView::Helpers::DateHelper

  def save_messages
    @message = current_site.messages.new
    @message.body = params[:body]
    @message.room_id= params[:room_id]
    @message.user_id= current_user.id
    @message.site_id= current_site.id
    @message.leido= 0   
    @message.save!           
  end

  def misms
         
    if params[:w].present?      
      @busca_single_room = current_site.rooms.michat(params[:w], current_user.id)
      if @busca_single_room.present?
        @single_room = current_site.rooms.find(@busca_single_room[0].id)
        @messages = @single_room.messages.order(created_at: :asc)
        quien= @single_room.participant_uno if @single_room.participant_uno!= current_user.id
        quien= @single_room.participant_dos if @single_room.participant_dos!= current_user.id
        @aquienenvia = current_site.users.find(quien)
        chat_leido        
      else  
        @single_room = current_site.rooms.new
        @single_room.participant_uno = current_user.id
        @single_room.participant_dos = params[:w].to_i
        @single_room.site_id = current_site.id
        @single_room.save!
        @messages = @single_room.messages.order(created_at: :asc)
        @aquienenvia = current_site.users.find(params[:w])
      end   
    end  

    if params[:id].present?
      @single_room = current_site.rooms.find(params[:id])
      @messages = @single_room.messages.order(created_at: :asc)
      quien= @single_room.participant_uno if @single_room.participant_uno!= current_user.id
      quien= @single_room.participant_dos if @single_room.participant_dos!= current_user.id
      @aquienenvia = current_site.users.find(quien)
      chat_leido
    end  
    
    @room = current_site.rooms.new
    @rooms = current_site.rooms.tengochat(current_user.id)

    if !cama_sign_in?
      render 'login'
    else
      render 'misms'  
    end 
    
  end  
  
  def carga_csms_ajax
    rooms=current_site.rooms.tengochat(current_user.id)
    cuantos = 0
    if rooms.count >0
        rooms.each do |room|
            cual_usu= room.participant_dos if room.participant_uno == current_user.id
            cual_usu= room.participant_uno if room.participant_dos == current_user.id
            cadaunoi=current_site.messages.deroom(room.id).deusr(cual_usu).noleido.count
            cuantos += cadaunoi
        end  
    end  
    contenido = '<a href="' + cama_misms_path + '">
                  <i class="fa fa-comment"></i> <span style="font-size: 11px;">' + cuantos.to_s + '</span>
                </a>'  
    respond_to do |format|
      format.html {render json:{ contenido: contenido.html_safe }}        
    end 
  end  

  def carga_mitarjeta_ajax
    @rooms = current_site.rooms.tengochat(current_user.id)
    contenido = ''  
    @rooms.each_with_index do |room, index|
                        clase =""
                        if room.id == params[:room_id]
                            clase = "miembro-activo"
                        end    
                        cual_usu= room.participant_dos if room.participant_uno == current_user.id
                        cual_usu= room.participant_uno if room.participant_dos == current_user.id
                        @user = current_site.users.find(cual_usu)
                        @nombre = @user.first_name + " " + @user.last_name
                        mensajes = current_site.messages.deroom(room.id)
                        cuantos = mensajes.deusr(cual_usu).noleido.count
                        ultima = Time.now
                        ultima = mensajes.last.created_at if cuantos > 0                                                         
                            
                        contenido+= '<div class="side-content ' + clase + '" id="id_chati_' + room.id.to_s + '">
                        <a href="' + cama_url_to_fixed("cama_misms_path", {id: room.id}) + '" class="hastaluego"> 
                            <div class="miembro d-flex align-items-center">
                                <div id="profile" class="" style="background-image:url(' + @user.decorate.the_avatar + '); margin-right:2em;"></div>
                                <div id="mensaje" class="d-flex">
                                    <div class="">
                                        <p><i class="fa fa-comment"></i> <span style="font-size: 11px;"> ' + @nombre + ' </span></p>
                                        <p class="subtitulo">' + distance_of_time_in_words(ultima, Time.now) + '</p>
                                    </div>
                                    <span class="badge">' + cuantos.to_s + '</span>
                                </div>
                            </div>
                        </a>                                 
                    </div>'                                    
    end 
                        
                
    respond_to do |format|
      format.html {render json:{ contenido: contenido.html_safe }}        
    end 
  end 

  def carga_chat_ajax
    
    @single_room = current_site.rooms.find(params[:room_id])
    @messages = @single_room.messages.order(created_at: :asc)
    
    contenido = ''
    @messages.each_with_index do |message,index|
      if current_user.id ==  message.user_id    
        cual = "repaly"         
      else    
          cual = "sender" 
      end
      contenido+= '<li class="' + cual + '">
                      <p>' + message.body + '</p>
                      <span class="time">' + distance_of_time_in_words(message.created_at, Time.now) + '</span>
                  </li>'
    end
    
    respond_to do |format|
      format.html {render json:{ contenido: contenido.html_safe }}        
    end   
  end  

  def guarda_chat_ajax
    sms = Plugins::CustomRegistro::Chat.new
    sms.id_usr_envia = current_user.id
    sms.id_usr_recibe = params[:aquien]
    sms.site_id = current_site.id
    sms.leido = 0
    sms.mensaje = params[:mensaje]
    sms.save!
  end  

  def chat_leido
    cual_usu= @single_room.participant_dos if @single_room.participant_uno == current_user.id
    cual_usu= @single_room.participant_uno if @single_room.participant_dos == current_user.id
    mensajesporleer=current_site.messages.deroom(@single_room.id).deusr(cual_usu)
    if mensajesporleer.count >0
      mensajesporleer.each do |mensaje|
        mensaje.leido = 1
        mensaje.save!
      end        
    end  
    
  end  

  def megusta_ajax
    megiustasa=current_site.megustas.porusr(current_user.id).pormuro(params[:muro_id])
    if megiustasa.present?
      id = 0
      current_site.megustas.find(megiustasa[0].id).destroy
    else
      nuevo_mgusta =   current_site.megustas.new     
      nuevo_mgusta.site_id =current_site.id
      nuevo_mgusta.muro_id =params[:muro_id]
      nuevo_mgusta.user_id =current_user.id
      nuevo_mgusta.save!      
      id = nuevo_mgusta.id
    end
    respond_to do |format|
      format.json{ render json: {muro_id: params[:muro_id], id: id, numero: current_site.megustas.pormuro(params[:muro_id]).count} }      
    end   
  end  

  def crea_come_ajax
    nuevo_comen= current_site.comentarios.new
    nuevo_comen.texto =params[:texto]
    nuevo_comen.site_id =current_site.id
    nuevo_comen.muro_id =params[:muro_id]
    nuevo_comen.user_id =current_user.id
    nuevo_comen.save!
  end  

  def lista_come_ajax
    contenido = '<div class="h6"> '+ (I18n.t "comentariosu",locale: params[:idiomaz]) +'</div>'
    @comentarios = current_site.comentarios.pormuro(params[:muro_id])
    @comentarios.each_with_index do |comentado,index|                                                           
            unusr = current_site.users.find_by_id(comentado.user_id)    
            resta = distance_of_time_in_words(comentado.created_at, Time.now) 
            contenido+='<div id="comentario">
                <div class="menu-badges">
                    <div id="profile" style="background-image:url(' + unusr.decorate.the_avatar + '); margin-right:2em;"></div>
                    <div class="user-comentario">
                        <strong>' + unusr.first_name + ' ' + unusr.last_name + '</strong>
                        <p class="subtitulo">' + resta + '</p>
                    </div>
                </div>
                <div class="comentario-contenido">
                    <p>' + comentado.texto+ '</p>
                </div>
            </div>'
    end
    contenido+='<p>&nbsp;</p>
    <div class="input-comentario input-group">
        <input type="text" id="texto_comen_' + params[:muro_id] + '" class="form-control" placeholder="'+ (I18n.t "comentaesta",locale: params[:idiomaz]) +'">
        <span class="input-group-btn">
        <button class="btn btn-primary" type="button" onclick="crear_comen(' + params[:muro_id] + ')">'+ (I18n.t "comentar",locale: params[:idiomaz]) +'</button>
        </span>
    </div>'
   
    respond_to do |format|
      format.html {render json:{ contenido: contenido.html_safe, numero: @comentarios.count }}        
    end   
       
end    

  def save_newusropr
    
    if buenos_parametros      
      nuevaclave = SecureRandom.alphanumeric(10)
      usuarionuevo = current_site.users.new      
      usuarionuevo.username = params[:email]
      usuarionuevo.role = "oportunidades"
      usuarionuevo.email = params[:email]
      usuarionuevo.password = nuevaclave    
      usuarionuevo.is_valid_email = true
      usuarionuevo.first_name = params[:nombre]
      usuarionuevo.last_name = params[:apellidos]
      usuarionuevo.direc = params[:direc]
      usuarionuevo.poblacion = params[:poblacion]
      usuarionuevo.zip = params[:zip]
      usuarionuevo.telf = params[:telf]
      usuarionuevo.estatus = "activo"
      usuarionuevo.cargo = " "
      usuarionuevo.save!    

      nueva_empresa= CamaleonCms::Post.new
      nueva_empresa.title = "<!--:es-->"+params[:empresa].to_s+"<!--:--><!--:en-->"+params[:empresa].to_s+"<!--:--><!--:pt-->"+params[:empresa].to_s+"<!--:-->"
      nueva_empresa.slug = "<!--:es-->"+params[:empresa].to_s.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')+"<!--:--><!--:en-->"+params[:empresa].to_s.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')+"<!--:--><!--:pt-->"+params[:empresa].to_s.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')+"<!--:-->"
      nueva_empresa.status= "published"
      nueva_empresa.visibility = "public"
      nueva_empresa.user_id=1
      nueva_empresa.taxonomy_id=37
      nueva_empresa.save!

      # campo adicional usuario => empresa

      nueva_relacion = CamaleonCms::CustomFieldsRelationship.new     
      nueva_relacion.objectid= usuarionuevo.id
      nueva_relacion.custom_field_id=76
      nueva_relacion.term_order=0
      nueva_relacion.object_class="User"
      nueva_relacion.value=nueva_empresa.id
      nueva_relacion.custom_field_slug= "empresa"
      nueva_relacion.group_number=0
      nueva_relacion.save!

      # Campos adicionales de la empresa => visible => "No"

      nueva_relacion2 = CamaleonCms::CustomFieldsRelationship.new     
      nueva_relacion2.objectid= nueva_empresa.id
      nueva_relacion2.custom_field_id=90
      nueva_relacion2.term_order=0
      nueva_relacion2.object_class="Post"
      nueva_relacion2.value=0
      nueva_relacion2.custom_field_slug= "visible"
      nueva_relacion2.group_number=0
      nueva_relacion2.save!

      # Campos adicionales de la empresa => estado => "Activo"

      nueva_relacion2 = CamaleonCms::CustomFieldsRelationship.new     
      nueva_relacion2.objectid= nueva_empresa.id
      nueva_relacion2.custom_field_id=86
      nueva_relacion2.term_order=0
      nueva_relacion2.object_class="Post"
      nueva_relacion2.value=1
      nueva_relacion2.custom_field_slug= "estado"
      nueva_relacion2.group_number=0
      nueva_relacion2.save!

      contenidoemail =t("contaprousr",lacontrasena: nuevaclave)           
          cama_send_email(params[:email],  t("subaprousr"),{content: contenidoemail}) 

          flash[:error] = ""
          flash[:success] = "Usuario creado exitosamente"
          redirect_to cama_login_path   
    else
      render 'nuevousuariop'
    end
    
  end  

  def guarda_pub_team
    keytoda= "baidatamediagrupokey"
    sield = "baidtagrupotk"
    URLcrypt.key = [keytoda].pack('H*')

    if params[:texto].present? || params[:adjunto].present? || params[:link].present?
      msg = nil
      error = []
      stat = 'success'    
      adonde =  request.referer    

      muro = current_site.muros.new
      muro.texto = params[:texto]
      
      muro.enlace = params[:link]
      muro.site_id = current_site.id
      muro.user_id = current_user.id
      muro.id_equipo = params[:id_equipo]
      muro.save!
      if params[:adjunto].present?
          archivo_nombre=URLcrypt.encode(URLcrypt.encode(muro.id.to_s+"|"+muro.user_id.to_s+"|"+muro.id_equipo.to_s+"|"+sield))
            parametros = {
              folder: "/workteams",          
              formats: "images,document",
              generate_thumb: true,          
              filename: archivo_nombre + File.extname(params[:adjunto])         
          }
        subida= upload_file(params[:adjunto],parametros)
        muro2 =current_site.muros.find(muro.id)
        muro2.nombre_img_doc= archivo_nombre + File.extname(params[:adjunto])    
        muro2.save!
      end
      
      redirect_to adonde
    end  
  end  

  def send_sms
    if params[:w].present?
      render 'send_sms'
    else
      render 'equipostrab'  
    end  
  end 

  def info_group
    if !cama_sign_in?
      render 'login'
    elsif params[:w].present?
      @post=current_site.posts.find_by_id(params[:w]).decorate
      render 'info_group'
    else
      render 'equipostrab'  
    end  
  end  

  def member_group
    if !cama_sign_in?
      render 'login'
    elsif params[:w].present?
      @user=current_site.users.find_by_id(params[:w]).decorate
      @post=current_site.posts.find_by_id(params[:g]).decorate
      @muros = current_site.muros.porequipo(params[:g]).porusr(params[:w]).paginate(:page => params[:page], :per_page => current_site.admin_per_page)            
      render 'member_group'
    else
      render 'equipostrab'  
    end  
  end  

  def media_group
    if params[:w].present?
      @post=current_site.posts.find_by_id(params[:w]).decorate
      render 'media_group'
    else
      render 'equipostrab'  
    end  
  end  

  def buenos_parametros
    if params[:email].present? && params[:nombre].present? && params[:apellidos].present? && params[:empresa].present?
      usuario_existe= current_site.users.find_by_email(params[:email])
      if usuario_existe.present?
        flash[:error] = "Usuario ya registrado!"
        return false
      end  
      return true
    else
      return false
    end
  end  

  def streamevents2    
    @evento = current_site.the_posts("events").find(params[:cualevt])
    if !cama_sign_in?
      render 'login'
    else
      render 'streamevents2'
    end  
  end

  def streamevents3    
    
    if !cama_sign_in?
      render 'login'
    else
      render 'streamevents3'
    end  
  end
  
  def convocatorias
    if !cama_sign_in?
      render 'login'
    else 
      render 'convocatorias'
    end  
  end  
  
  def oportunidad
    render 'oportunidad'
  end  

  def inscoport
    if !cama_sign_in?
      render 'login'
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]      
      render 'inscoport'
    end  
    
  end  
  
  def evalcurse        
    if token_valido
      
      if current_site.tests.where(:token => params[:token]).present?        
        redirect_to action: :testready        
      else
        flash[:error] = ""
         @elcurso = current_site.the_posts("cursos").find(@id_curso)
         
        render 'encuesta'  
      end  
    else
        flash[:error] = "Error en el enlace, consulte con el administrador"
        render 'errortoken'  
    end    
  end  

  def save_valora_curso
    
    keytoda= "baidatacursokey"
    sield = "baidtacursetk"
    URLcrypt.key = [keytoda].pack('H*')
    eltoken=URLcrypt.encode(URLcrypt.encode(URLcrypt.encode(params[:id_inscrito]+"|"+params[:id_curso]+"|"+sield)))
    quiz= current_site.tests.new
    quiz.id_curso=params[:id_curso] 
    quiz.id_inscrito=params[:id_inscrito] 
    quiz.token = eltoken
    quiz.save
    params[:quiz].each do |k,v|
      respuesta = current_site.responses.new
      respuesta.campo = k
      respuesta.valor = v
      respuesta.test_id = quiz.id
      respuesta.save
    end  
    redirect_to action: :testready
  end    

  def testready
    flash[:success] = "Encuesta completada satisfactoriamente"
    render 'testready'
  end  

  def token_valido
    if params[:token].present? && valida_token
      return true
    else
      return false
    end    
  end  

  def valida_token
    keytoda= "baidatacursokey"
    sield = "baidtacursetk"
    URLcrypt.key = [keytoda].pack('H*')
    #eltoken=URLcrypt.encode("494|255"+sield)
    # nA7hs8bAhbrh3z6c4jAg49rvmjtxmn634m7wyqlnnj7g46jxgyzw46rx487xAysbgr8dqz6rp36dk6tsgf6t4nrt
    @id_inscrito = 0
    @id_curso = 0    
    eltoken = URLcrypt.decode(URLcrypt.decode(URLcrypt.decode(params[:token])))
    
    separar = eltoken.split('|')
    if separar.size == 3 && separar[2] == sield
      @id_inscrito = separar[0].to_i
      @id_curso = separar[1].to_i
      if current_site.inscritos.where(:id => @id_inscrito).present?
        return true
      else
        return false  
      end  
    else      
      return false  
    end    
  end


  def login
    flash[:error] = ""
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
    if !cama_sign_in?
      render 'login'
    else
      render 'myprofile'  
    end  
  end

  def nuevousuariop
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
    if !cama_sign_in?
      render 'nuevousuariop'
    else
      render 'myprofile'  
    end  
  end

  def nuevousuario
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
    if !cama_sign_in?
      render 'nuevousuario'
    else
      render 'index'  
    end  
  end

  def events
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
    render 'events'
  end

  def noticias
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
    render 'noticias'
  end

  def cursos
    #session[:return_to] = "/cursos"
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
    #if !cama_sign_in?
    #  render 'login'
    #else            
      render 'cursos'  
    #end  
  end

  def radar_baidata       
      render 'radar_baidata'      
  end
  
  def register
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
    if !cama_sign_in?
      render 'register'
    else
      render 'index'  
    end  
  end

  def juntadir    
  end  

  def streamevents     
      
      if cama_sign_in?
        @evento = current_site.the_posts("events").find(params[:id])
       # session[:return_to] = "/themes/baidata_theme/streamevents/" + params[:id]
        render 'streamevents'
      else
        render 'login'  
      end       
    
  end

  def asamblea    
  end  

  def admin
    if !cama_sign_in?
      login
    else
      if current_user.client?
        redirect_to cama_root_path
      else
        redirect_to cama_admin_dashboard_path
      end  
    end    
  end

  def save_login
    if params[:username].present? && params[:password].present?
      @user = current_site.users.find_by_username(params[:username])
      
      if login_user_with_password(params[:username], params[:password])
        flash[:error] = ""   
        if(@user.estatus=="activo")
          login_user(@user, false, (session[:return_to] || cama_myprofile_path))
          session.delete(:return_to)
        else
          flash[:error] = 'Invalid access'
          render 'login'
        end  
      else
        flash[:error] = 'Invalid access'
        render 'login'
      end
    else
      flash[:error] = 'Invalid access'
      render 'login'
    end
    flash[:error] = ""  
  end

  def forgot
    flash[:error] = ""   
    @user = current_site.users.new
    # get form reset password
    if params[:h]
      @user = current_site.users.where(password_reset_token: params[:h]).first
      if @user.nil?
        flash[:error] = t('camaleon_cms.admin.login.message.forgot_url_incorrect')
        redirect_to cama_forgot_path
        return
      elsif @user.password_reset_sent_at < 2.hours.ago
        flash[:error] = t('camaleon_cms.admin.login.message.forgot_expired')
        redirect_to cama_login_path
      else
        # saved new password
        if params[:user].present?
          if @user.update(params[:user].permit(:password, :password_confirmation))
            flash[:notice] = t('camaleon_cms.admin.login.message.reset_password_succes')
            redirect_to cama_login_path
            return
          else
            flash[:error] = t('camaleon_cms.admin.login.message.reset_password_error')
          end
        end
        @form_reset = true
        render "forgot"
        return
      end
    end

    # TODO: Move this out of the controller
    # send email reset password
    if params[:user].present?
      data_user = user_permit_data
      @user = current_site.users.find_by_email(data_user[:email])
      if @user.present?
        send_password_reset_email(@user)
        flash[:notice] = t('camaleon_cms.admin.login.message.send_mail_succes')
        redirect_to cama_login_path
        return
      else
        flash[:error] = t('camaleon_cms.admin.login.message.send_mail_error')
        @user = current_site.users.new(data_user)
      end
    end
  end  

  def user_permit_data
    params.require(:user).permit!
  end

  def myprofile   
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]      
    end              
  end

  def logout
    params[:return_to] = cama_root_path
    cama_logout_user
  end

  def actualiza_usuario
    @user = current_site.users.find(params[:id])    
    if @user.update(user_params)
      @user.set_metas(params[:meta]) if params[:meta].present?
      @user.set_field_values(params[:field_options])
      r = {user: @user, message: t('camaleon_cms.admin.users.message.updated'), params: params}; hooks_run('user_after_edited', r)
      flash[:notice] = r[:message]
      r={user: @user}; hooks_run('user_updated', r)
      redirect_to action: :misdatos
    else
      render 'misdatos'
    end
  end

  def user_params
    parameters = params.require(:user)
    parameters.permit(:username, :email, :first_name, :last_name, :dni, :direc, :poblacion, :zip, :telf, :cargo)
  end
   
  def actualiza_usuario_ajax
      @user = current_site.users.find(params[:user_id])
      update_session = current_user_is?(@user)
      @user.update(params.require(:password).permit!)
      render inline: @user.errors.full_messages.join(', ')
      # keep user logged in when changing their own password
      update_auth_token_in_cookie @user.auth_token if update_session && @user.saved_change_to_password_digest?
      return
  end    

  def current_user_is?(user)
      user_auth_token_from_cookie == user.auth_token rescue false
  end

  def update_auth_token_in_cookie(token)
      return unless cookie_auth_token_complete?
      current_token = cookie_split_auth_token
      updated_token = [token, *current_token[1..-1]]
      cookies[:auth_token] = updated_token.join("&")
  end

  def forma_contacto
      msg = nil
      error = []
      stat = 'success_confirmation'
      error << t('camaleon_cms.admin.users.message.error_captcha', default: 'Invalid captcha value') if !verify_recaptcha
      if params[:fields][:nomape].empty? || params[:fields][:email].empty?
        error << t('camaleon_cms.admin.users.message.empty', default: 'Empty value')
      end  
      cuale =  false
      cuale = true if error.length>0
      elmotivo = ""
      if params[:fields][:laop] == "1" && !cuale
        # ser miembro
        adjuntos = []
        current_theme.get_fields_grouped(["adjunt_correo"]).each do |adjunto|
           adjuntos << "public/" + adjunto["adjunt_correo"].first
        end  

        conteido = t("estimadoa") + params[:fields][:nomape] + " <br> " + current_theme.the_field('contenido-sol-baidata').translate(I18n.locale.to_s.upcase)     
        cama_send_email(params[:fields][:email], current_theme.the_field('asunto-sol-baidata').translate(I18n.locale.to_s.upcase) ,
        {content: conteido, attachs: adjuntos })  
        error << t("gracias_contacto")
        elmotivo = "Solicitar ser miembro de BAIDATA para poder beneficiarme de todas sus oportunidades y ventajas"
      elsif   params[:fields][:laop] == "2" && !cuale
        elmotivo = "Suscribirme a la newsletter y estar al día de todo lo que sucede en BAIDATA"
        conecta_campain_monitor()
        conteido = t("estimadoa") + params[:fields][:nomape] + " <br> " + current_theme.the_field('contenido-solicitud-newsletter').translate(I18n.locale.to_s.upcase)     
        cama_send_email(params[:fields][:email], current_theme.the_field('asunto-solicitud-newsletter').translate(I18n.locale.to_s.upcase) ,
        {content: conteido }) 
      elsif   params[:fields][:laop] == "3" && !cuale
        elmotivo = "Realizar una consulta"        
      end
      
      elasuntoi = "Solicitud desde la web"
      elcontenidoi = "<strong>Nombre y Apellidos: </strong> " + params[:fields][:nomape] + " <br>
      <strong>Empresa: </strong> " + params[:fields][:empre] + "  <br>
      <strong>Teléfono: </strong>" + params[:fields][:telf] + " <br>
      <strong>Correo electrónico:</strong> " + params[:fields][:email] + "  <br>
      <strong>Motivo:</strong> " + elmotivo + "  <br>
      <strong>Mensaje:</strong> " + params[:fields][:sms]
      cama_send_email('info@baidata.eu', elasuntoi,{content: elcontenidoi })  
      res = {errors: error, redirect: request.referer, status: stat}; hooks_run('formula_error', res)            
     
     respond_to do |format|       
        format.json{ render json: {message: res[:errors], error: cuale} }        
      end
     
  end

  def conecta_campain_monitor

        auth = {api_key: 'uB4C1nTmC4NeMAMw8BXpFAB0Bj86hOYbrq+udUt0ADwyiWH8szDxPDG6zU+UOnKnCo3tuVwWoJDTkf/qRKgmDkHB3adGFeoWL/e/ExjuDoOx0iUdf3dZNinChf6cJuqEVvVhEZDoQovIcvvjp25Cww=='}

        list_id = 'e73b2fe49b11c4b3de28125093010433'        

        begin
          CreateSend::Subscriber.add(auth, list_id, params[:fields][:email].to_s,params[:fields][:nomape].to_s, [],true,"Yes")
        rescue CreateSend::BadRequest => exception
          fail "could not add #{params[:fields][:email]}/#{params[:fields][:nomape]}, ex= #{exception} codigo=#{exception.data.Code} mensaje=#{exception.data.Message}"
        end
  end  

  def inf_inicitva_ajx
      cadapto=current_site.the_posts("radar-baidata").where(id:params[:id])[0]
      color="#5B05CB" if (cadapto.get_field("tipo-de-iniciativa")=="1")   
      color="#82378E" if (cadapto.get_field("tipo-de-iniciativa")=="2")
      contenido="<h3 style='color:"+color+"'>"+cadapto.title.translate(params[:idiomaz])+"</h3>"
      contenido+="<div class='conscroll'><hr>"
      contenido+="<p>"+cadapto.get_field("pagina-web")+"</p>"
      contenido+="<hr>"      
      contenido+="<p>"+cadapto.get_field("contacto-principal")+"</p>"
      contenido+="<hr>"
      if (cadapto.get_field("tipo-de-iniciativa")=="1")
        cadapto.get_fields_grouped(["nombre-ed"]).each do |nombr|
          contenido+="<p>"+nombr["nombre-ed"].first+"</p>"
        end  
      elsif
        cadapto.get_fields_grouped(["nombre-cu"]).each do |nombr|
          contenido+="<p>"+nombr["nombre-cu"].first+"</p>"
        end 
      end 
      contenido+="<hr>"
      contenido+="<p><b>"+(I18n.t "madurez",locale: params[:idiomaz])+" : </b>"  
      if (cadapto.get_field("tipo-de-iniciativa")=="1")
        vector= [ (I18n.t "maed_1",locale: params[:idiomaz]), (I18n.t "maed_2",locale: params[:idiomaz]), (I18n.t "maed_3",locale: params[:idiomaz]), (I18n.t "maed_4",locale: params[:idiomaz])]
        contenido+=vector[cadapto.get_field("madurez-espacio-de-datos").to_i-1]      
      elsif 
        vector= [ (I18n.t "macu_1",locale: params[:idiomaz]),(I18n.t "macu_2",locale: params[:idiomaz]),(I18n.t "macu_3",locale: params[:idiomaz]),(I18n.t "macu_4",locale: params[:idiomaz])]
        contenido+=vector[cadapto.get_field("madurez-espacio-de-datos").to_i-1] 
      end  
      contenido+="</p>"
      contenido+="<hr>"
      contenido+="<p><b>"+(I18n.t "sector",locale: params[:idiomaz])+" : </b>"
      vector_sec= [ (I18n.t "movilidad",locale: params[:idiomaz]), (I18n.t "smartcity",locale: params[:idiomaz]), (I18n.t "automocion",locale: params[:idiomaz]), (I18n.t "otrossect",locale: params[:idiomaz])]
      contenido+=vector_sec[cadapto.get_field("sector").to_i-1]      
      contenido+=" - " + cadapto.get_field("otro-sector").translate(params[:idiomaz]) if cadapto.get_field("sector")=="4" && cadapto.get_field("otro-sector").present?
      contenido+="</p>"
      contenido+="<hr>"
      contenido+="<p><b>"+(I18n.t "tecnologiat",locale: params[:idiomaz])+" : </b>"  + "IDS" if cadapto.get_field("tecnologia")=="1"
      contenido+="<p><b>"+(I18n.t "tecnologiat",locale: params[:idiomaz])+" : </b>"  + (I18n.t "otra",locale: params[:idiomaz]) + " - " + cadapto.get_field("otra-tecnologia").translate(params[:idiomaz]) if cadapto.get_field("tecnologia")=="2"
      contenido+="<hr>"
      vector_cpm= [ (I18n.t "cpm_1",locale: params[:idiomaz]), (I18n.t "cpm_2",locale: params[:idiomaz]), (I18n.t "cpm_3",locale: params[:idiomaz]), (I18n.t "cpm_4",locale: params[:idiomaz]), (I18n.t "cpm_5",locale: params[:idiomaz]), (I18n.t "cpm_6",locale: params[:idiomaz]), (I18n.t "cpm_7",locale: params[:idiomaz])]
      losco=cadapto.get_fields_grouped(["componentes-desplegados"])[0]["componentes-desplegados"]
      losco.each do |compp|
        contenido+="<p>"
        contenido+=vector_cpm[compp.to_i-1]
        contenido+=" - "+ cadapto.get_field("otros-componentes-desplegados").translate(params[:idiomaz]) if compp=="7" &&  cadapto.get_field("otros-componentes-desplegados").present?
        contenido+="</p>"
      end  
      contenido+="<hr>"
      contenido+="<h5>" +  (I18n.t "descripcion",locale: params[:idiomaz]) + " </h5>" 
      contenido+="<p>"+ cadapto.get_field("breve-descripcion").translate(params[:idiomaz])+"</p>"
      contenido+="<hr>"
      contenido+="<h5>" +  (I18n.t "retos",locale: params[:idiomaz]) + " </h5>"  if (cadapto.get_field("tipo-de-iniciativa")=="2")
      contenido+="<p>"+ cadapto.get_field("retos-afrontados").translate(params[:idiomaz])+"</p>"  if (cadapto.get_field("tipo-de-iniciativa")=="2")
      contenido+="<hr>" if (cadapto.get_field("tipo-de-iniciativa")=="2")
      contenido+="<h5>" +  (I18n.t "beneficios",locale: params[:idiomaz]) + " </h5>" 
      contenido+="<p>"+ cadapto.get_field("principales-beneficios").translate(params[:idiomaz])+"</p>"


      contenido+="</div>"
      respond_to do |format|
        format.html {render html: contenido.html_safe}        
      end   
         
  end  

  def misdatos
      if !cama_sign_in?
        login
      else  
        @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
        @mi_empresa_id=@user.get_field("empresa")
        @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
        r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
        hooks_run('actualiza_usuario', r)        
      end            
  end

  def adminempre
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
      r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
      hooks_run('actualiza_usuario', r)        
    end         
  end  

  def adminempre_datos
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
      r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
      hooks_run('actualiza_usuario', r)        
    end         
  end  

  def adminempre_usrs
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
      r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
      hooks_run('actualiza_usuario', r)        
    end         
  end  

  def equipostrab
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
      r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
      hooks_run('actualiza_usuario', r)        
    end         
  end 

  def misoportunidades
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object      
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
      r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
      hooks_run('actualiza_usuario', r)        
    end         
  end 

  def reuniones_junta
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
      r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
      hooks_run('actualiza_usuario', r)        
    end  
  end  
  
  def miformacion
    if !cama_sign_in?
      login
    else  
      @user = params[:user_id].present? ? current_site.the_user(params[:user_id].to_i).object : cama_current_user.object
      @mi_empresa_id=@user.get_field("empresa")
      @miempresa=current_site.the_posts("empresas").where(:id => @user.get_field("empresa"))[0]
      r = {user: @user,miempresa: @miempresa,mi_empresa_id: @mi_empresa_id, render: 'form' }
      hooks_run('actualiza_usuario', r)        
    end         
  end  
end    