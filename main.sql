START TRANSACTION;
WITH sessions_map AS (select s2.id as id, min(s1.id) as new_id
                      from sessions s1
                               left join sessions s2
                                         on s1.start_time = s2.start_time and
                                            s1.session_configuration_id = s2.session_configuration_id
                      group by s1.start_time, s1.session_configuration_id, s2.id)
UPDATE
    session_members
    LEFT JOIN sessions_map
on session_members.session_id = sessions_map.id
    SET session_members.session_id = sessions_map.new_id;

with session_members_delete_ids
         AS (SELECT min(id) as id
             FROM session_members
             group by session_id, client_id)
delete
from session_members
where id not in (select id from session_members_delete_ids);

with session_delete_ids AS (SELECT min(id) as id
                            FROM sessions
                            group by start_time, session_configuration_id)
delete
from sessions
where id not in (select * from session_delete_ids);

COMMIT;