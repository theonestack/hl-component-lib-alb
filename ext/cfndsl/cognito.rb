
def test_shared_function(alb_config={})
  policies = []
  print alb_config
  alb_config.each do |name,policy|
    print name
    print policy
  end
  return 0
end
