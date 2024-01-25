@AbapCatalog.sqlViewName: 'Z_S_TEST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'TEst'
define view Z_CDAS_TEST as  select from ettifn as ett 
inner join easts as easts on easts.anlage = ett.anlage //eanlh.anlage // Installation
inner join eprofass as epro on epro.logikzw = easts.logikzw // Logical Register
inner join eprofvalstat as epst on epst.profile = epro.profile // Profile {
{ 
ett.anlage,
easts.logikzw,
epro.profrole,
epst.profile,
epst.stat,
easts.ab,
epst.datefrom   
}
