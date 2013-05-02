require 'spec_helper'

describe QueryController do
  before(:each) do
    @user = User.create(calnetID: 181758)
    @admin = Admin.create(calnetID: 181860, email: "test_admin@isg2.berkeley.edu")
    @query = @admin.queries.create(description: "get all users", query_string: "SELECT * FROM users")
  end

  describe "admin" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(@admin.calnetID.to_s)
    end

    context "makes good requests:" do
      it "get index" do
        get 'index'
        response.should be_success
      end

      it "get/post create" do
        get 'create'
        response.should be_success

        post 'create', { description: "get all nodes", query_string: "SELECT * FROM nodes" }
        response.should be_redirect
        response.should redirect_to query_path
        queries = Query.find_all_by_description("get all nodes")
        queries.should have(1).item
        queries[0].query_string.should == "SELECT * FROM nodes"
      end

      it "get/post edit" do
        get 'edit', { id: @query.id }
        response.should be_success

        post 'edit', { id: @query.id, description: "get all nodes", query_string: "SELECT * FROM nodes" }
        response.should be_redirect
        response.should redirect_to query_path
        Query.find_all_by_description("get all users").should be_blank
        queries = Query.find_all_by_description("get all nodes")
        queries.should have(1).item
        queries[0].query_string.should == "SELECT * FROM nodes"
      end

      it "delete destroy" do
        delete 'destroy', { id: @query.id }
        response.should be_redirect
        response.should redirect_to query_path
        flash[:error].should be_nil
        flash[:notice].should match "Successfully removed query '.+'\."
      end

      it "get/post run" do
        get 'run'
        response.should be_success

        # run a SQL query by manually typing a query
        post 'run', { query_string: "SELECT * FROM users;" }
        response.should be_success

        post 'run', { format: :json, query_string: "SELECT * FROM users;" }
        response.should be_success
        ActiveSupport::JSON.decode(response.body).should_not be_nil # JSON_parsable?
        expect {
          @resp = JSON.parse(response.body)
        }.to_not raise_error(JSON::ParserError)
        @resp.should include("headers")
        @resp.should include("results")
        @resp["headers"].should == User.attribute_names
        @resp["results"].should have(1).item
        @resp["results"][0].should have(User.attribute_names.count).items

        # run a saved SQL query
        post 'run', { id: @query.id }
        response.should be_success

        post 'run', { format: :json, id: @query.id }
        response.should be_success
        ActiveSupport::JSON.decode(response.body).should_not be_nil # JSON_parsable?
        expect {
          @resp = JSON.parse(response.body)
        }.to_not raise_error(JSON::ParserError)
        @resp.should include("headers")
        @resp.should include("results")
        @resp["headers"].should == User.attribute_names
        @resp["results"].should have(1).item
        @resp["results"][0].should have(User.attribute_names.count).items
      end
    end

    context "makes bad requests:" do
      it "get/post create" do
        post 'create', { query_string: "SELECT * FROM nodes" }
        response.should be_success
        flash[:error].should == "Description required!"
        Query.find_all_by_description("get all nodes").should be_blank

        post 'create', { description: "get all nodes" }
        response.should be_success
        flash[:error].should == "SQL query string required!"
        Query.find_all_by_description("get all nodes").should be_blank

        post 'create', { description: "", query_string: "SELECT * FROM nodes" }
        response.should be_success
        flash[:error].should == "description error: can't be blank"
        Query.find_all_by_description("get all nodes").should be_blank

        post 'create', { description: "get all nodes", query_string: "" }
        response.should be_success
        flash[:error].should == "query_string error: can't be blank"
        Query.find_all_by_description("get all nodes").should be_blank
      end

      it "post edit" do
        # no description
        post 'edit', { id: @query, query_string: "SELECT * FROM nodes" }
        response.should be_success
        flash[:error].should == "Description required!"
        query = Query.first
        query.description.should == "get all users"
        query.query_string.should == "SELECT * FROM users"

        # empty description
        post 'edit', { id: @query, description: "", query_string: "SELECT * FROM nodes" }
        response.should be_success
        flash[:error].should == "Can't update query because:\ndescription error: can't be blank"
        query = Query.first
        query.description.should == "get all users"
        query.query_string.should == "SELECT * FROM users"

        # no query_string
        post 'edit', { id: @query, description: "get all nodes" }
        response.should be_success
        flash[:error].should == "SQL query string required!"
        query = Query.first
        query.description.should == "get all users"
        query.query_string.should == "SELECT * FROM users"

        # empty query_string
        post 'edit', { id: @query, description: "get all nodes", query_string: "" }
        response.should be_success
        flash[:error].should == "Can't update query because:\nquery_string error: can't be blank"
        query = Query.first
        query.description.should == "get all users"
        query.query_string.should == "SELECT * FROM users"

        # invalid id
        post 'edit', { id: @query.id+1, description: "get all nodes", query_string: "SELECT * FORM nodes" }
        response.should be_success
        flash[:error].should == "Could not find query with id '#{@query.id+1}'"

        # edit query of other admins
        admin2 = Admin.create(calnetID: 181916, email: "test_admin2@isg2.berkeley.edu")
        query2 = admin2.queries.create(description: "get all resources", query_string: "SELECT * FROM resources")
        post 'edit', { id: query2.id, description: "get all complaints", query_string: "SELECT * FROM complaints"}
        response.should be_redirect
        response.should redirect_to query_path
        flash[:error].should == "You cannot edit a query belongs to another admin"
      end

      it "delete destroy" do
        delete 'destroy', { id: @query.id+1 }
        response.should be_redirect
        response.should redirect_to query_path
        flash[:error].should == "Could not find query with id '#{@query.id+1}'"

        stubbed_query = stub(destroy: false, admin_id: @admin.id, errors: {reason: "dunno"})
        Query.stub(:find).and_return(stubbed_query)
        delete 'destroy', { id: @query.id }
        response.should be_redirect
        response.should redirect_to query_path
        flash[:error].should == "Can't delete query because:\nreason error: dunno"
      end

      it "post run" do
        post 'run'
        response.should be_success
        flash[:error].should == "Query string required"

        # run a syntactically incorrect SQL query
        post 'run', { query_string: "bad query" }
        response.should be_success

        post 'run', { format: :json, query_string: "bad query" }
        response.should be_success
        expect {
          @resp = JSON.parse(response.body)
        }.to_not raise_error(JSON::ParserError)
        @resp.should include("error")
        @resp["error"].should match /^Mysql2::Error.*$/

        # run a query invalid id
        post 'run', { id: @query.id+1 }
        response.should be_redirect
        response.should redirect_to query_path
        flash[:error].should == "Could not find query with id '#{@query.id+1}'" 

        post 'run', { format: :json, id: @query.id+1 }
        response.should be_success
        expect {
          @resp = JSON.parse(response.body)
        }.to_not raise_error(JSON::ParserError)
        @resp.should include("error")
        @resp["error"].should == "Could not find query with id '#{@query.id+1}'"

        # run a query belongs to another admin
        admin2 = Admin.create(calnetID: 181916, email: "test_admin2@isg2.berkeley.edu")
        query2 = admin2.queries.create(description: "get all resources", query_string: "SELECT * FROM resources")

        post 'run', { id: query2.id }
        response.should be_success
        flash[:error].should == "You cannot run a query belongs to another admin"

        post 'run', { format: :json, id: query2.id }
        response.should be_success
        expect {
          @resp = JSON.parse(response.body)
        }.to_not raise_error(JSON::ParserError)
        @resp.should include("error")
        @resp["error"].should == "You cannot run a query belongs to another admin"
      end
    end
  end

  describe "user" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(@user.calnetID.to_s)
    end
    
    context "can't make requests:" do
      it "get index" do
        get 'index'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end

      it "get/post create" do
        get 'create'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/

        post 'create'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end

      it "get/post edit" do
        get 'edit', { id: @query.id }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/

        post 'edit', { id: @query.id }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end

      it "delete destroy" do
        delete 'destroy', { id: @query.id }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end

      it "get/post run" do
        get 'run'
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/

        tables = ActiveRecord::Base.connection.tables.delete_if { |t| t == "schema_migrations" }
        post 'run', { query_string: "DROP TABLE #{tables.join(', ')};" }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
        
        post 'run', { id: @query.id }
        response.should be_redirect
        response.should redirect_to :root
        flash[:error].should match /Error: You don't have the privilege to perform this action/
      end
    end
  end

  describe "non-user" do
    before(:each) do
      CASClient::Frameworks::Rails::Filter.fake(nil, nil)
    end

    context "can't make request:" do
      it "get index" do
        get 'index'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*$/
      end

      it "get/post create" do
        get 'create'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*create$/

        post 'create'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*create$/
      end

      it "get/post edit" do
        get 'edit', { id: @query.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*edit$/

        post 'edit', { id: @query.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*edit$/
      end

      it "delete destroy" do
        delete 'destroy', { id: @query.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*destroy$/
      end

      it "get/post run" do
        get 'run'
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*run$/

        tables = ActiveRecord::Base.connection.tables.delete_if { |t| t == "schema_migrations" }
        post 'run', { query_string: "DROP TABLE #{tables.join(', ')};" }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*run$/

        post 'run', { format: :json, query_string: "DROP TABLE #{tables.join(', ')};" }
        response.body.should == " "

        post 'run', { id: @query.id }
        response.should be_redirect
        response.redirect_url.should match /^https:\/\/auth.berkeley.edu\/cas\/login\?service=.+test.+host.+query.*run$/
      end
    end
  end
end
