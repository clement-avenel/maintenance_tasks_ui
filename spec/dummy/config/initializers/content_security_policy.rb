# Be sure to restart your server when you modify this file.

# Very permissive CSP for dummy app (testing only)
# In production apps, configure CSP as needed for your security requirements

Rails.application.configure do
  config.content_security_policy do |policy|
    # Allow everything from self and unsafe-inline/unsafe-eval (very permissive for testing)
    policy.default_src :self, :unsafe_inline, :unsafe_eval, :data, :blob, :http, :https
    policy.font_src    :self, :unsafe_inline, :data, :http, :https
    policy.img_src      :self, :unsafe_inline, :data, :http, :https, :blob
    policy.object_src   :self, :unsafe_inline
    policy.script_src   :self, :unsafe_inline, :unsafe_eval, :http, :https
    policy.script_src_elem :self, :unsafe_inline
    policy.style_src    :self, :unsafe_inline, :http, :https
    # style-src-elem is needed for <style> tags and <link rel="stylesheet">
    policy.style_src_elem :self, :unsafe_inline, :http, :https
    policy.connect_src  :self, :http, :https
  end
  
  # Disable nonce requirements
  config.content_security_policy_nonce_generator = nil
  config.content_security_policy_nonce_directives = nil
end
