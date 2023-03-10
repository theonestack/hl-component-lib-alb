
def rule_actions(actions)
  response = []
  actions.each do |action,config|
    case action
    when 'targetgroup'
      response << forward(config)
    when 'redirect'
      response << redirect(config)
    when 'fixed'
      response << fixed(config)
    end
  end
  return response
end

def forward(value)
  return { Type: "forward", Order: 2000, TargetGroupArn: Ref("#{value}TargetGroup") }
end

def redirect(value)
  case value
  when 'http_to_https'
    return http_to_https_redirect()
  else
    return { Type: "redirect", Order: 5000, RedirectConfig: value }
  end
end

def cognito(user_pool_id, user_pool_client_id, user_pool_domain_name)
  return { Type: "authenticate-cognito",
          Order: 1, 
          AuthenticateCognitoConfig: {
           UserPoolArn: user_pool_id, 
           UserPoolClientId: user_pool_client_id,
           UserPoolDomain: user_pool_domain_name
          } 
        }
end

def fixed(value)
  response = { Type: 'fixed-response', Order: 10000, FixedResponseConfig: {}}
  response[:FixedResponseConfig][:ContentType] = value['type'] if value.has_key?'type'
  response[:FixedResponseConfig][:MessageBody] = value['body'] if value.has_key? 'body'
  response[:FixedResponseConfig][:StatusCode] = value['code']
  return response
end

def http_to_https_redirect()
  return { Type: "redirect", Order: 7000,
    RedirectConfig: {
      Host: '#{host}',
      Path: '/#{path}',
      Port: '443',
      Protocol: 'HTTPS',
      Query: '#{query}',
      StatusCode: 'HTTP_301'
    }
  }
end