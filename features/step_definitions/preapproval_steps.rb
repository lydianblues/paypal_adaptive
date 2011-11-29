When /^I create a preapproval with default options$/ do

  # Log in to the PayPal developer site.
  visit("http://developer.paypal.com")
  fill_in 'Email Address', :with => "mbs@thirdmode.com"
  fill_in 'Password', :with => "zalogu53"
  check 'Keep me logged in'
  find(:css, "[value^=Log]").click
  
  # Go to the Payments page of the demo app.
  visit(payments_path)
  sleep(4)
  click_button('Preapprove')
  
  # On the PayPal site, we have a login, so click to get to the 
  # login page.
  find("[name=login_button]").click
  
  # Fill in our login info and submit.
  fill_in("Email address", :with => 'buyer_1233697850_per@thirdmode.com')
  fill_in("Password", :with => '233697837')
  find(:css, "#submitLogin").click
  
  # Approve the preapproval.
  find(:css, "[value=Approve]").click 
  page.should have_content("successfully signed up for preapproved payments")
  
  # Click the link to redirect to Payments#index
  find(:css, "[value=Return]").click
  
  # Now we're back on the Payments Page.
  page.should have_content("Payment Scenarios")
  
  # Find the preapproval key on this page.
  puts "Preapproval key is " + find(:css, "table.preapprovals tr:nth-child(2) td:nth-child(4)").text
  
end