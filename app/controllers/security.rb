# frozen_string_literal: true

require_relative './app' 
require 'roda'
require 'rack/ssl-enforcer' 
require 'secure_headers'

module CheckHigh
    # Security configuration for the API
  class App < Roda
    plugin :environments
    plugin :multi_route

    configure :production do
      use Rack::SslEnforcer, hsts: true
    end

    use SecureHeaders::Middleware

    SecureHeaders::Configuration.default do |config|
      config.cookies = {
        secure: true, # mark all cookies as "Secure"
        httponly: true, # mark all cookies as "HttpOnly"
        samesite: {
          strict: true # mark all cookies as SameSite=Strict
        }
      }

      FONT_SRC = %w[https://cdn.jsdelivr.net].freeze 
      SCRIPT_SRC = %w[https://cdn.jsdelivr.net].freeze 
      STYLE_SRC = %w[https://bootswatch.com
                     https://pro.fontawesome.com
                     https://cdn.jsdelivr.net
                     https://code.jquery.com 
                     https://maxcdn.bootstrapcdn.com
                     https://mycdn.com].freeze

      config.x_frame_options = 'DENY' # Do not let this page be displayed in a frame
      config.x_content_type_options = 'nosniff' # Do not let anyone change HTTPS
      config.x_xss_protection = '1' # Block response if a script found in user input
      config.x_permitted_cross_domain_policies = 'none' # Don't let others embed me
      config.referrer_policy = 'origin-when-cross-origin' # Only report this site's hostname if user nagivates to other site

      config.csp = {
        # "meta" values: these keys will be inserted into header
        report_only: false,     # false: disable unwanted features; true: report but don't disable
        preserve_schemes: true, # default: false. Schemes are removed from host sources to save bytes and discourage mixed content

        # directive values: these keys + values be inserted into header
        default_src: %w['self'], # Use 'self' if a *_src configuration not defined
        child_src: %w['self'], #
        connect_src: %w[wws:], # valid sources for fetch, XMLHttpRequest, WebSocket, and EventSource connections
        img_src: %w[mycdn.com data:],
        font_src: %w['self' data:] + STYLE_SRC,
        script_src: %w['self'] + STYLE_SRC,
        style_src: %W['self' 'unsafe-inline'] + STYLE_SRC,
        style_src_elem: %W['self' 'unsafe-inline']+ STYLE_SRC,
        form_action: %w['self'], # valid endpoints for form actions
        frame_ancestors: %w['self'], # valid parents that may embed a page using the <frame> and <iframe> elements
        object_src: %w['self'],
        block_all_mixed_content: true, # see http://www.w3.org/TR/mixed-content/

        report_uri: %w[/security/report_csp_violation] # submit CSP violations by POST method
      }
    end

    route('security') do |routing|
      # POST security/report_csp_violation 
      routing.post 'report_csp_violation' do
        puts "CSP VIOLATION: #{request.body.read}" 
      end
    end 
  end
end