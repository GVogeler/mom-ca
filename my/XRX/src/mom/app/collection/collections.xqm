xquery version "3.0";

module namespace collections="http://www.monasterium.net/NS/collections";

declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";

declare function collections:by-country($db-base-collections) {

    for $collections in $db-base-collections
    let $country := $collections//cei:country/text()
    group by $country
    order by $country
    return
    if($country) then collections:list($country, $collections) else()
};

declare function collections:by-category($db-base-collections) {

    for $collections in $db-base-collections
    let $keyword := $collections//xrx:keyword/text()
    group by $keyword
    order by $keyword
    return
    if($keyword) then collections:list($keyword, $collections) else()
};

declare function collections:by-user($db-base-collections) {

    for $collections in $db-base-collections
    let $user := $collections//atom:author/atom:email/text()
    group by $user
    order by $user
    return
    if($user) then collections:list(user:firstname-name($user), $collections) else()
};

declare function collections:recently-added($db-base-collections) {

    <div>
        <div class="country-name"></div>
        <ul class="nostyle">
            {
            for $collection in $db-base-collections
            let $collection-name := normalize-space(($collection//cei:titleStmt/cei:title/text(), $collection//cei:provenance/text())[1])
            let $collection-atomid := $collection//atom:id/text()
            let $collection-id := (tokenize($collection-atomid, '/'))[3]
            let $date := replace(substring-before($collection//atom:published/text(), 'T'), '-', '/')
            order by $date descending
            return
            <li><a href="{ conf:param('request-root') }{ $collection-id }/collection">{ $collection-name }</a><span class="collections-date">&#160;{ $date }</span></li>
            }
        </ul>
    </div>
};

declare function collections:list($label as xs:string, $collections) as element() {
    <div>
    {let $alphabet := distinct-values($collections//(cei:titleStmt/cei:title/text()|cei:provenance/text())[1]/upper-case(substring(normalize-space(),1,1)))
    return (
      <div class="country-name" id="{$label}">{ $label }</div>
      <!-- 
      Start with a "ToC": default by initial of the cei:title or cei:provenance 
      and thenn add for each group a list of collections starting with the initial 
      -->
      <div id="ToC" class="ToC"><p class="ToC">{
        for $initial in $alphabet
        order by $initial
        return 
            <span class="Initiale">[<a href="#{$initial}">{$initial}</a>]</span>
      }</p></div>), (<div>
      {
        for $initial in $alphabet
        order by $initial
        return 
          <div>
            <h3 class="alphabet" id="{$initial}">{$initial}</h3>
            <ul class="nostyle">
              {
                for $collection in $collections//atom:entry[.//(cei:titleStmt/cei:title/text()|cei:provenance/text())[starts-with(upper-case(normalize-space(.)), $initial)][1]]
                let $collection-name := normalize-space(($collection//cei:titleStmt/cei:title/text(), $collection//cei:provenance/text())[1])
                let $collection-atomid := $collection//atom:id/text()
                let $collection-id := (tokenize($collection-atomid, '/'))[3]
                order by $collection-name
                return
                   <li><a href="{ conf:param('request-root') }{ $collection-id }/collection">{ $collection-name }</a></li>
              }
            </ul>
          </div>
        }
        </div>)
      }</div>
};