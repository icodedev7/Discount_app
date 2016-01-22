class ShopifyController < ApplicationController
# Skip the login requirement
skip_before_filter :require_login
skip_before_filter :verify_authenticity_token
def authorize
unless params[:shop].present?
render :text => "shop parameter required" and return
end
# Redirect to the authorization page
redirect_to "https://
#{params[:shop].gsub(".myshopify.com","")}.myshopify.com
admin/oauth/authorize?client_id=46177b20f3c16d64efd5d5dfcb7e916d&
scope=read_products,read_orders,read_customers"
end
end