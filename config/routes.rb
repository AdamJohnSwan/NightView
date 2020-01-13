Rails.application.routes.draw do
	root 'space#new'
	post '/' => 'space#create'
	get '/s/(:image)' => 'space#show', as: 'image'
	get '/index' => 'space#index'
end
