Sequel.migration do
  up do
    create_table(:matches) do
      primary_key :id
      Integer :bluescore
      Integer :redscore

      Integer :r1
      Integer :r2
      Integer :b1
      Integer :b2

      String :r1done
      String :r2done
      String :b1done
      String :b2done

    end

    # Convert all user email data to email records


  end

  down do


    # Convert all email records back to user email data

    drop_table(:matches)
  end
end