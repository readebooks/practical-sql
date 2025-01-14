---------------------------------------------------------------------------
-- 실용 SQL
-- by Anthony DeBarros
----------------------------------------------------------------------------

-- 코드 11-1: 2014~2018년의 ACS 5개년 추정치 테이블 생성 및 데이터 가져오기

CREATE TABLE acs_2014_2018_stats (
    geoid text CONSTRAINT geoid_key PRIMARY KEY,
    county text NOT NULL,
    st text NOT NULL,
    pct_travel_60_min numeric(5,2),
    pct_bachelors_higher numeric(5,2),
    pct_masters_higher numeric(5,2),
    median_hh_income integer,
    CHECK (pct_masters_higher <= pct_bachelors_higher)
);

COPY acs_2014_2018_stats
FROM 'C:\YourDirectory\acs_2014_2018_stats.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM acs_2014_2018_stats;

-- 코드 11-2: corr(Y, X)를 사용하여 교육과 소득 간의 관계 측정하기

SELECT corr(median_hh_income, pct_bachelors_higher)
    AS bachelors_income_r
FROM acs_2014_2018_stats;

-- 코드 11-3: 추가 변수에 corr(Y, X) 사용하기

SELECT
    round(
      corr(median_hh_income, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_income_r,
    round(
      corr(pct_travel_60_min, median_hh_income)::numeric, 2
      ) AS income_travel_r,
    round(
      corr(pct_travel_60_min, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_travel_r
FROM acs_2014_2018_stats;

-- 코드 11-4: 회귀 기울기 및 절편 함수

SELECT
    round(
        regr_slope(median_hh_income, pct_bachelors_higher)::numeric, 2
        ) AS slope,
    round(
        regr_intercept(median_hh_income, pct_bachelors_higher)::numeric, 2
        ) AS y_intercept
FROM acs_2014_2018_stats;

-- 코드 11-5: 결정계수 또는 r제곱 계산하기

SELECT round(
        regr_r2(median_hh_income, pct_bachelors_higher)::numeric, 3
        ) AS r_squared
FROM acs_2014_2018_stats;

-- 보너스: 통계 함수
-- 전체 인구의 분산
SELECT var_pop(median_hh_income)
FROM acs_2014_2018_stats;

-- 전체 인구의 표준편차
SELECT stddev_pop(median_hh_income)
FROM acs_2014_2018_stats;

-- 코드 11-6: rank() 및 dense_rank() 윈도우 함수 사용하기

CREATE TABLE widget_companies (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    company text NOT NULL,
    widget_output integer NOT NULL
);

INSERT INTO widget_companies (company, widget_output)
VALUES
    ('Dom Widgets', 125000),
    ('Ariadne Widget Masters', 143000),
    ('Saito Widget Co.', 201000),
    ('Mal Inc.', 133000),
    ('Dream Widget Inc.', 196000),
    ('Miles Amalgamated', 620000),
    ('Arthur Industries', 244000),
    ('Fischer Worldwide', 201000);

SELECT
    company,
    widget_output,
    rank() OVER (ORDER BY widget_output DESC),
    dense_rank() OVER (ORDER BY widget_output DESC)
FROM widget_companies
ORDER BY widget_output DESC;

-- 코드 11-7: PARTITION BY를 사용하여 그룹 내에 rank() 적용하기

CREATE TABLE store_sales (
    store text NOT NULL,
    category text NOT NULL,
    unit_sales bigint NOT NULL,
    CONSTRAINT store_category_key PRIMARY KEY (store, category)
);

INSERT INTO store_sales (store, category, unit_sales)
VALUES
    ('Broders', 'Cereal', 1104),
    ('Wallace', 'Ice Cream', 1863),
    ('Broders', 'Ice Cream', 2517),
    ('Cramers', 'Ice Cream', 2112),
    ('Broders', 'Beer', 641),
    ('Cramers', 'Cereal', 1003),
    ('Cramers', 'Beer', 640),
    ('Wallace', 'Cereal', 980),
    ('Wallace', 'Beer', 988);

SELECT
    category,
    store,
    unit_sales,
    rank() OVER (PARTITION BY category ORDER BY unit_sales DESC)
FROM store_sales
ORDER BY category, rank() OVER (PARTITION BY category 
        ORDER BY unit_sales DESC);

-- 코드 11-8: 인구조사 카운티 기업 패턴 데이터에 대한 테이블 생성 및 채우기

CREATE TABLE cbp_naics_72_establishments (
    state_fips text,
    county_fips text,
    county text NOT NULL,
    st text NOT NULL,
    naics_2017 text NOT NULL,
    naics_2017_label text NOT NULL,
    year smallint NOT NULL,
    establishments integer NOT NULL,
    CONSTRAINT cbp_fips_key PRIMARY KEY (state_fips, county_fips)
);

COPY cbp_naics_72_establishments
FROM 'C:\YourDirectory\cbp_naics_72_establishments.csv'
WITH (FORMAT CSV, HEADER);

SELECT *
FROM cbp_naics_72_establishments
ORDER BY state_fips, county_fips
LIMIT 5;

-- 코드 11-9: 인구가 50,000명 이상인 카운티에서 인구 1,000명 비율로 기업 찾기

SELECT
    cbp.county,
    cbp.st,
    cbp.establishments,
    pop.pop_est_2018,
    round( (cbp.establishments::numeric / pop.pop_est_2018) * 1000, 1 )
        AS estabs_per_1000 
FROM cbp_naics_72_establishments cbp JOIN us_counties_pop_est_2019 pop 
    ON cbp.state_fips = pop.state_fips 
    AND cbp.county_fips = pop.county_fips 
WHERE pop.pop_est_2018 >= 50000 
ORDER BY cbp.establishments::numeric / pop.pop_est_2018 DESC;

-- 코드 11-10: 데이터를 내보내기 위한 이동 평균 계산

CREATE TABLE us_exports (
    year smallint,
    month smallint,
    citrus_export_value bigint,	
    soybeans_export_value bigint
);

COPY us_exports
FROM 'C:\YourDirectory\us_exports.csv'
WITH (FORMAT CSV, HEADER);

-- 월별 감귤류 수출량 확인
SELECT year, month, citrus_export_value
FROM us_exports
ORDER BY year, month;

-- 롤링 평균 계산
SELECT year, month, citrus_export_value,
    round(   
       avg(citrus_export_value) 
            OVER(ORDER BY year, month 
                 ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 0)
       AS twelve_month_avg
FROM us_exports
ORDER BY year, month;

