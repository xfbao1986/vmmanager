# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:hostname) { |n| "vmhostname%03d" % n }
  sequence(:amount) { |n| n*1024 }

  factory :vm do
    hostname
    user        "xcp-taro"
  end
end
