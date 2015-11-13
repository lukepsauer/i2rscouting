Sequel.migration do
  up do
    create_table(:teams) do
      primary_key :id

      #Team Info

      Integer :number
      String :name
      String :teamMate
      Integer :competition
      Integer :trustworthiness
      FalseClass :completed
      Integer :picked

      #Tele-Op/Endgame

      Integer :climb
      Integer :debris
      FalseClass :bar
      Integer :climbers

      #Autonomous

      Integer :autoHeight
      Integer :climbersShelter
      FalseClass :delays
      FalseClass :beacon
      Integer :reliability


      #Robot
      String :matches
      Integer :guess
      String :comments
      String :photos


    end

    # Convert all user email data to email records

  end

  down do

    # Convert all email records back to user email data

    drop_table(:teams)
  end
end
