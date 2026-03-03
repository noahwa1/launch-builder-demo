class Users::SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    if resource.admin?
      manage_root_path
    elsif resource.creator?
      portal_root_path
    else
      root_path
    end
  end

  def after_sign_out_path_for(_resource)
    new_user_session_path
  end
end
