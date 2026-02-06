select avg(round(extract(epoch from end_session - start_session)/60)) as avg_len
          , case when reg_date between '2022-11-01'
            and  '2022-12-31' then 'когорта 11-12.2022' else 'остальные когорты' end as cohort
from skygame.game_sessions as s 
left join skygame.users as u
  on s.id_user = u.id_user
where end_session - start_session > interval '5 minute'
group by cohort

with k_faktor as 
                (select (sum(ref_reg) / count(r.id_user)) * (count(ref_reg) / count(distinct u.id_user)::float) 
                 as k_faktor1
                from skygame.referral as r
                 right join skygame.users as u
                  on r.id_user = u.id_user
                ),
      avg_ref as     
              (select u.id_user,
                count(r.ref_reg) as cnt_inv,
                sum(coalesce(r.ref_reg, 0)) as cnt_reg 
                from skygame.users u
                join skygame.referral r
                  on u.id_user = r.id_user
                group by u.id_user
               ),
     cohort_mass as          
              (select date_trunc('month', reg_date) as mm
                    , count (id_user) as  cnt_user
                    from skygame.users
                    group by mm
              )
select(select avg(cnt_user) from cohort_mass) * (select k_faktor1 from k_faktor) as result