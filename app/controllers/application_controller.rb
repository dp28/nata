class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  after_filter :flash_to_headers

  def flash_to_headers
    return unless request.xhr? && !flash.empty?
    response.headers['X-Message'] = flash_message
    response.headers["X-Message-Type"] = flash_type.to_s
    flash.discard # don't want the flash to appear when you reload page
  end

  private
    FLASH_TYPES = [:danger, :warning, :notice, :success]

    def flash_message
      FLASH_TYPES.each do |type|
        return flash[type] unless flash[type].blank?
      end
    end

    def flash_type
      FLASH_TYPES.each do |type|
        return type unless flash[type].blank?
      end
    end
end
