
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
