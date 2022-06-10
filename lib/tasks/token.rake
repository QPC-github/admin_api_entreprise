namespace :token do
  desc 'Blacklist a token (and create a new one)'

  task :blacklist, [:token_id] => :environment do |_, args|
    token = JwtAPIEntreprise.find(args.token_id)

    if token.blacklisted?
      puts 'Token already blacklisted'
      fail
    end

    copy = token.dup
    copy.roles = token.roles
    copy.save

    token.update(blacklisted: true)

    end_message(token)
  end

  private

  def end_message(token)
    puts 'New Token is available in user dashboard'
    puts 'Token to blacklist:'
    puts token.rehash
    puts 'Add the token to the blaclist in Ansible'
    puts '  ansible-vault edit secrets/siade_jwt_black_and_white_list.yml'
    puts 'And deploy the file (leave few hours/days to the user to change token)'
    puts '  ansible-playbook siade_production.yml --tags jwt-blacklist'
  end
end