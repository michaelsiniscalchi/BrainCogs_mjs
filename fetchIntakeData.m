function [intake_data, block_data] = fetchIntakeData( key )
query = proj(...
    action.Weighing, 'date(weighing_time)->administration_date', 'weight', 'weigh_person')...
    * action.WaterAdministration & key;
intake_data = fetch(query,'*');
block_data = fetch(behavior.TowersBlock & key,'reward_mil');