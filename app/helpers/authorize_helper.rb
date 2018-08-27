class AuthorizeHelper

  def self.authorize(request)
    @tokenstr = request.headers['Authorization']
    @token = Token.find_by token: @tokenstr
    return @token if not @token

    #if not @token.is_valid?
    #@token.destroy
    #return nil
    #end
    return @token.user
  end

  def self.auth_and_set_account(request, id)
    user = AuthorizeHelper.authorize(request)
    account = Account.find(id)
    if user == nil or account.user != user or account.is_deleted
      return nil
    else
      return account
    end
  end

  end
