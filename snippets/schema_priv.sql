select concat('GRANT ', perm_string[3]::text, ' ON ', object_type, ' "', nspname::text, '" TO "', rolname, '"') as "GRANTS" 
from (
select nspname,
object_type,
(string_to_array(rtrim(ltrim(aclexplode(nspacl)::text,'('),')'),',')) as perm_string
from  (select nspname, 
  'SCHEMA' as object_type,
  nspacl from pg_namespace 
   where nspname not like 'pg_%' and nspname not in ('public', 'information_schema')
 union
 select nspname, 
  case(defaclobjtype)
	  when 'S' then 'SEQUENCE'
      when 'r' then 'TABLE'
      when 'm' then 'TABLE'
      when 'v' then 'TABLE'
      else 'other'
      end,
  d.defaclacl from pg_default_acl d
    join pg_namespace s on s.oid=defaclnamespace 
    where nspname not like 'pg_%' and nspname not in ('public', 'information_schema')

)s
where nspname not like 'pg_%' and nspname not in ('public', 'information_schema')

) b 
join pg_roles r on r.oid=b.perm_string[2]::oid
where rolname = '{user}'
