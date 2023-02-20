

#TODO Move all actions etc to here  

## APPLICATION-LOAD-BALANCER

## hl-component-application-loadbalancer `actions.rb`

# def cognito_exists(listener)
#   if !listener['rules'].nil?
#     listener['rules'].each do |rule|
#       rule['actions'].each do |action, value|
#         if action == 'cognito'
#           return true
#         end
#       end
#     end
#     return false
#   end
# end


# def cognito_rule(cfn,listener)
#   #Skip all non cognito rules
#   listener['rules'].each do |rule|
#     rule['actions'].each do |action,config|
#       case action
#       when 'targetgroup'
#         next
#       when 'redirect'
#         next
#       when 'cognito'
#         return cognito(cfn) 
#       when 'fixed'
#         next
#       end
#     end
#   end
# end

def rule_actions(cfn, actions)
  response = []
  actions.each do |action,config|
    case action
    when 'targetgroup'
      response << forward(config)
    when 'redirect'
      response << redirect(config)
    when 'cognito'
      next #Skip as added to default actions on listener #TODO check if this is still needed
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

def cognito(cfn)
  return { Type: "authenticate-cognito",
          Order: 1, 
          AuthenticateCognitoConfig: {
           UserPoolArn: cfn.Ref(:UserPoolId),
           UserPoolClientId: cfn.Ref(:UserPoolClientId),
           UserPoolDomain: cfn.Ref(:UserPoolDomainName)
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

#####