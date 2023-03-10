class EventsController < ApplicationController
# before_action :check_owner, only: [:update, :destroy]


    def index
        render json: Event.all
    end

    def show
        event = Event.find_by(id: params[:id])
        render json: event, status: :ok
    rescue ActiveRecord::RecordInvalid => e 
        render json: {errors: e.record.errors.full_messages}, status: 406
    end

    # def create
    #     event = Event.create!(event_params)
    #     render json: event, status: :created
    # rescue ActiveRecord::RecordInvalid => e
    #     render json: {errors: e.record.errors.full_messages}, status: :unprocessable_entity
    # end

    def create
        @event = Event.new(event_params)
        if @event.save
          @event.update(
            latitude: Geocoder.search("#{@event.address} + #{@event.city} + #{@event.state} + #{@event.zipcode}").first.coordinates[0], 
            longitude: Geocoder.search("#{@event.address} + #{@event.city} + #{@event.state} + #{@event.zipcode}").first.coordinates[1]
            )
          render json: @event, status: :created
        else
          render json: {errors: @event.errors}, status: :unprocessable_entity
        end
    end

    def update
        @event = Event.find_by(id: params[:id])
        if @event.update(event_params)
            render json: @event, status: :ok
        else
            render json: {error: 'Something went wrong'}, status: :unprocessable_entity
        end
    end
    
    def destroy 
        event = Event.find_by(id: params[:id])
        if event.present?
            event.destroy
            head :no_content
        else 
            render json: {error: "event not found"}, status: 404
        end
    end 

    

    private

    def event_params
        params.require(:event).permit(:name, :description, :address, :city, :state, :zipcode, :date, :time, :user_id)
    end

    def check_owner
        unless Event.find(params[:id]).user_id == session[:user_id]
            head :forbidden
        end
    end



end
