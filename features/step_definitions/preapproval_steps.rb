When /^I create a preapproval with default options$/ do

  # get_via_redirect payments_path
  # <input id="preapproval_max_total_payments" name="preapproval[max_total_payments]" type="text" value="$100.00" />
  # assert_select "[name=?]", "preapproval[max_total_payments]", "$100.00"
  #assert_select "a[href=?]", new_movie_path, "Add Movie"
  
  Capybara.current_driver = :selenium
  
  # Log in to the PayPal developer site.
  visit("http://developer.paypal.com")
  fill_in 'Email Address', :with => "mbs@thirdmode.com"
  fill_in 'Password', :with => "zalogu53"
  check 'Keep me logged in'
  find(:css, "[value^=Log]").click
  
  # Go to the Payments page of the demo app.
  visit(payments_path)
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
  find(:css, "[value=Return]").click
  
  # Now we're back on the Payments Page.
  page.should have_content("Payment Scenarios")
  
  # Find the preapproval key on this page.
  puts "Preapproval key is " + find(:css, "table.preapprovals tr:nth-child(2) td:nth-child(4)").text
  find(:css, "table.preapprovals tr:nth-child(2) td:nth-child(5)").click
  save_and_open_page
  page.should have_content("Success")
  
  Capybara.use_default_driver
end