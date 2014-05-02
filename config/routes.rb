Iter1::Application.routes.draw do
  get "home/index"
  root :to => "home#index"
  devise_for :users

  # namespace :api do

  #   namespace :v1 do
  #     devise_scope :user do
  #       post 'registrations' => 'registrations#create', :as => 'register'
  #       post 'sessions' => 'sessions#create', :as => 'login'
  #       delete 'sessions' => 'sessions#destroy', :as => 'logout'
  #       post 'activities' => 'users#createActivity'
  #       get 'activities' => 'users#myActivities'
  #       get 'upcomingActivities' => 'users#myUpcomingActivities'

  #       get 'getActivity' => 'users#getActivity'

  #       # added action routes for adding friends and confirm friends
  #       post 'requestFriend' => 'users#requestFriend'
  #       post 'confirmFriend' => 'users#confirmFriend'
  #       get 'getPendingFriends' => 'users#getPendingFriends'
  #       get 'getSentRequests' => 'users#getSentRequests'
  #       post 'deleteRequest' => 'users#deleteRequest'

  #       post 'searchUser' => 'users#searchUser'

  #       get 'getFriends' => 'users#getFriends'
  #       post 'joinActivity' => 'users#joinActivity'
  #       get 'getFriendsActivities' => 'users#getFriendsActivities'
  #       post 'getActivityAttendees' => 'users#getActivityAttendees'
        
  #       post '/TESTAPI/resetFixture' => 'users#resetFixture'
  #       post '/TESTAPI/unitTests' => 'users#unitTests'
        
  #     end 
  #   end

    
  # end


  devise_scope :user do

    post 'searchUser' => 'users#searchUser'
    post 'registrations' => 'users#create', :as => 'register'
    post '/TESTAPI/resetFixture' => 'users#resetFixture'
    post '/TESTAPI/unitTests' => 'users#unitTests'
    post 'updateMyProfile' => 'users#updateMyProfile'
    post 'updatePassword' => 'users#updatePassword'
    get 'getMyProfile' => 'users#getMyProfile'

    post 'sessions' => 'sessions#create', :as => 'login'
    delete 'sessions' => 'sessions#destroy', :as => 'logout'
    

    get 'upcomingActivities' => 'activities#myUpcomingActivities'
    get 'getActivity' => 'activities#getActivity'
    get 'activities'  => 'activities#myActivities'
    get 'todos'       => 'activities#myTodos'
    get 'getTodo'       => 'activities#getActivity'
    get 'friendsActivities' => 'activities#getFriendsActivities'
    get 'friendsTodos' => 'activities#getFriendsTodos'
    post 'activities' => 'activities#createActivity'
    post 'joinActivity' => 'activities#joinActivity'
    post 'getActivityAttendees' => 'activities#getActivityAttendees'
    post 'inviteActivity' => 'activities#inviteActivity'
    post 'confirmActivity' => 'activities#confirmActivity'
    post 'getActivityAttendees' => 'activities#getActivityAttendees'
    post 'todoFollowers' => 'activities#getTodoFollowers'
    post 'updateActivityRole' => 'activities#updateActivityRole'

    get 'getFriends' => 'friendships#getFriends'
    get 'getPendingFriends' => 'friendships#getPendingFriends'
    get 'getSentRequests' => 'friendships#getSentRequests'
    post 'requestFriend' => 'friendships#requestFriend'
    post 'confirmFriend' => 'friendships#confirmFriend'
    post 'deleteRequest' => 'friendships#deleteRequest'
    post 'deleteActivity' => "activities#deleteActivity"

    post 'updateProfile'  => "users#updateMyProfile"
    post 'updatePassword' => "users#updatePassword"

  end 
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
