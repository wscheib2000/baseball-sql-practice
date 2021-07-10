/*
  Selects player IDs, years, and weighted TTO above yearly average for starting pitching
  seasons since 1990
*/
SELECT tbl.player_id
  , tbl.year
  , tbl.weighted_TTO - yearly_avgs.yearly_avg AS weighted_TTO_above_yearly_avg
FROM
  (
    /* Calculate weighted TTO */
    SELECT tmp.player_id
      , tmp.year
      , ROUND( 100 *
            (
              0.286*tmp.K +
              -0.311*tmp.BB +
              -0.3365*tmp.HBP +
              -0.186*tmp.IBB +
              -1.395*tmp.HR
            ) / tmp.PA_against, 4) AS weighted_TTO
    FROM
      (
        /*
          Calculate plate appearances, innings pitched, and proportion of games started
          Makes for simpler calculations and WHERE statement in outer scope
          Uses GROUP BY with SUM to combine stat lines for players who spent time with more 
          than one team in a season
        */
        SELECT p.playerID AS player_id
          , p.yearID AS year
          , ROUND(CAST(SUM(p.GS) AS REAL) / SUM(p.G), 3) AS GS_prop
          , SUM(p.IPouts)/3 AS innings_pitched
          , SUM(p.IPouts) + SUM(p.BB) + SUM(p.HBP) + SUM(p.IBB) + SUM(p.H) AS PA_against
          , SUM(BB) AS BB
          , SUM(HBP) AS HBP
          , SUM(IBB) AS IBB
          , SUM(p.HR) AS HR
          , SUM(p.SO) AS K
        FROM PITCHING p
        GROUP BY p.playerID, p.yearID
      ) AS tmp
    /*
      Filter for pitcing seasons in which the pitcher started at least 75% of their games,
      pitched in 1990 or later, and pitched at leasst 100 innings
    */
    WHERE tmp.GS_prop > 0.75 AND tmp.year >= 1990 AND tmp.innings_pitched >= 100
  ) AS tbl
/* Joins with yearly averages */
LEFT JOIN
(
  /* Compute yearly averages */
  SELECT p.yearID AS year
    , ROUND(
      100 * (
          0.286*SUM(p.SO) +
          -0.311*SUM(p.BB) +
          -0.3365*SUM(p.HBP) +
          -0.186*SUM(p.IBB) +
          -1.395*SUM(p.HR)
        ) / (
          SUM(p.IPouts) +
          SUM(p.BB) +
          SUM(p.HBP) +
          SUM(p.IBB) +
          SUM(p.H)
        )
      , 4
    ) AS yearly_avg
  FROM PITCHING p
  GROUP BY p.yearID
) AS yearly_avgs
ON tbl.year = yearly_avgs.year
ORDER BY tbl.weighted_TTO - yearly_avgs.yearly_avg DESC
;