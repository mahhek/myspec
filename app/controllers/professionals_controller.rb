class ProfessionalsController < ApplicationController
  # GET /professionals
  # GET /professionals.xml
  before_filter :login_required, :warning
    access_control do
    allow :admin
    end
  def index
    @professionals = Professional.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @professionals }
    end
  end

  # GET /professionals/1
  # GET /professionals/1.xml
  def show
    @professional = Professional.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @professional }
    end
  end

  # GET /professionals/new
  # GET /professionals/new.xml
  def new
    @professional = Professional.new
    @certificates = Certification.all
    @divisions = Division.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @professional }
    end
  end

  # GET /professionals/1/edit
  def edit
    @professional = Professional.find(params[:id])
  end

  # POST /professionals
  # POST /professionals.xml
  def verify
    @professional = Professional.find_by_token(params[:token])
    @professional.status = "received"
    @professional.save
    flash[:notice] = "Professional Successfully V erified"
    redirect_to :controller => "professionals", :action => "new"
  end
  def create
    @professional = Professional.new(params[:professional])
    date = Time.now
    @professional.expiry_date = date.to_time.advance(:months => 12).to_date
    @professional.token = make_token
      if @professional.save
        flash[:notice] = 'Professional was successfully created and sent for approval.'
        Notifier.deliver_professional_sent(@professional)
        Notifier.deliver_professional_developer(@professional)
        redirect_to :action => "new"
      else
        @certificates = Certification.all
        @divisions = Division.all
        render :action => "new"
   
      end
  
  end

  # PUT /professionals/1
  # PUT /professionals/1.xml
  def update
    @professional = Professional.find(params[:id])

    respond_to do |format|
      if @professional.update_attributes(params[:professional])
        format.html { redirect_to(@professional, :notice => 'Professional was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @professional.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /professionals/1
  # DELETE /professionals/1.xml
  def destroy
    @professional = Professional.find(params[:id])
    @professional.destroy
    redirect_to registered_professionals_path
   
  end
end
