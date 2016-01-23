class SessionsController < ApplicationController
  def new
    authenticate if params[:shop].present?
  end

  def create
    authenticate
  end

  def show
    if response = request.env['omniauth.auth']
      sess = ShopifyAPI::Session.new(params[:shop], response['credentials']['token'])
      session[:shopify] = sess
      flash[:success] = "Logged in"
      redirect_to return_address
    else
      flash[:danger] = "Could not log in to Shopify store."
      redirect_to :action => 'new'
    end
  end

  def destroy
    session[:shopify] = nil
    flash[:success] = "Successfully logged out."

    redirect_to :action => 'new'
  end

  protected

  def authenticate
    if shop_name = sanitize_shop_param(params)
      redirect_to "https://#{params[:shop].gsub(".myshopify.com","")}.myshopify.com/admin/oauth/authorize?client_id=46177b20f3c16d64efd5d5dfcb7e916d&scope=read_products,read_orders,read_customers,write_themes,write_script_tags,&redirect_uri=https://discountap.herokuapp.com/auth/shopify/callback&state=Callback"
    else
      redirect_to return_address
    end
  end

  def return_address
    session[:return_to] || root_url
  end

  def sanitize_shop_param(params)
    return unless params[:shop].present?
    name = params[:shop].to_s.strip
    name += '.myshopify.com' if !name.include?("myshopify.com") && !name.include?(".")
    name.sub('https://', '').sub('http://', '')

    u = URI("https://#{params[:shop].gsub(".myshopify.com","")}.myshopify.com")
    u.host.ends_with?("myshopify.com") ? u.host : nil
  end
end
