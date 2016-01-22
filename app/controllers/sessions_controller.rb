class SessionsController < ApplicationController
  def new
    authenticate if params[:shop].present?
  end

  def create
    authenticate
  end

  def show
    if response = request.env['omniauth.auth']
      sess = ShopifyAPI::Session.new(params[:shop], response['0090e669972e03310e790fe0f9d920a']['0225495e177ecaa0a9031090f623e239-1453454948'])
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
      redirect_to "/auth/shopify?shop=#{shop_name}"
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

    u = URI("http://#{name}")
    u.host.ends_with?("myshopify.com") ? u.host : nil
  end
end
