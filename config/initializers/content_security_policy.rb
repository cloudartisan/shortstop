# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
#
# This was entirely commented out while every page rendered inline <script>
# blocks and pulled Bootstrap and Chart.js from a CDN. Those scripts are now
# Stimulus controllers and the libraries are vendored, so the policy can be
# strict: everything executable comes from this origin.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self
    policy.connect_src :self
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
  end

  # Generate session nonces for permitted importmap and inline scripts.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
