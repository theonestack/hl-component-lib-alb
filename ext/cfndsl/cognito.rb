

#TODO Move all actions etc to here  

## APPLICATION-LOAD-BALANCER

def cognito_alb(user_pool_arn, user_pool_client_id, user_pool_domain)
  #Required, create with the other component 
 # -UserPoolArn
 # -UserPoolClientId
 # -UserPoolDomain
 return { Type: "authenticate-cognito", 
          AuthenticateCognitoConfig: {
           UserPoolArn: user_pool_arn,
           UserPoolClientId: user_pool_client_id,
           UserPoolDomain: user_pool_domain
        } }
end

## hl-component-application-loadbalancer `actions.rb`
def rule_actions(cfn, actions)
  response = []
  actions.each do |action,config|
    case action
    when 'targetgroup'
      response << forward(config)
    when 'redirect'
      response << redirect(config)
    when 'cognito'
      response << cognito(cfn, config)
    when 'fixed'
      response << fixed(config)
    end
  end
  return response
end

def forward(value)
  return { Type: "forward", TargetGroupArn: Ref("#{value}TargetGroup") }
end

def redirect(value)
  case value
  when 'http_to_https'
    return http_to_https_redirect()
  else
    return { Type: "redirect", RedirectConfig: value }
  end
end

def cognito(cfn, value)
  #Required, create with the other component 
  # -UserPoolArn
  # -UserPoolClientId
  # -UserPoolDomain
  return cognito_alb(cfn.Ref(:UserPoolArn),cfn.Ref(:UserPoolClientId),cfn.Ref(:UserPoolDomain))
end

def fixed(value)
  response = { Type: 'fixed-response', FixedResponseConfig: {}}
  response[:FixedResponseConfig][:ContentType] = value['type'] if value.has_key?'type'
  response[:FixedResponseConfig][:MessageBody] = value['body'] if value.has_key? 'body'
  response[:FixedResponseConfig][:StatusCode] = value['code']
  return response
end

def http_to_https_redirect()
  return { Type: "redirect",
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

#####