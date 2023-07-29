# 실용 SQL: PostgreSQL로 시작하는 데이터 스토리텔링 가이드북

## FAQ, 업데이트, 오탈자 정보

자주 하는 질문(FAQ)와 내용 업데이트, 오탈자 정보를 업로드 하는 페이지입니다.

오류, FAQ를 기록하는 문서입니다.



책내용을 결과가 이상하게 나오는 부분이 있어서 질문 드립니다.

SELECT president, speech_date,
    ts_headline(speech_text, to_tsquery('english', 'transportation & !roads'),
                'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@
    to_tsquery('english', 'transportation & !roads')
ORDER BY speech_date;

-- result
president, speech_date, ts_headline
"Harry S. Truman"	"1947-01-06"	"Mr. President, Mr. Speaker, Members of the"
"Harry S. Truman"	"1949-01-05"	"Mr. President, Mr. Speaker, Members of the"
"John F. Kennedy"	"1961-01-30"	"capacity. Obtaining additional air <transport> mobility--and obtaining"
"Lyndon B. Johnson"	"1964-01-08"	"Mr. Speaker, Mr. President, Members of the"
"Lyndon B. Johnson"	"1967-01-10"	"Mr. Speaker, Mr. Vice President, distinguished Members"
"Richard M. Nixon"	"1971-01-22"	"Mr. Speaker, Mr. President, my colleagues in"
"Richard M. Nixon"	"1972-01-20"	"Mr. Speaker, Mr. President, my colleagues in"
"Gerald R. Ford"	"1976-01-19"	"Mr. Speaker, Mr. Vice President, Members of"
"Ronald Reagan"	"1984-01-25"	"Mr. Speaker, Mr. President, distinguished Members of"
"Ronald Reagan"	"1985-02-06"	"Mr. Speaker, Mr. President, distinguished Members of"
"George Bush"	"1990-01-31"	"Mr. President, Mr. Speaker, Members of the"
"George Bush"	"1991-01-29"	"Mr. President and Mr. Speaker and Members"
"William J. Clinton"	"2000-01-27"	"Mr. Speaker, Mr. Vice President, Members of"
"George W. Bush"	"2002-01-29"	"Thank you very much. Mr. Speaker, Vice"
"Barack Obama"	"2016-01-12"	"Thank you. Mr. Speaker, Mr. Vice President"

ts_headline 열에 <transport> 처럼 검색어가 강조되서 나타내야 되지만
일부 열에서... 
"Mr. President, Mr. Speaker, Members of the" 또는 
"Mr. Speaker, Mr. Vice President, distinguished Members" 와 같이
검색어가 없는 경우가 있는데 이유가 무엇일까요?

아래와 같이 to_tsquery() 함수 사용하떼 'english' 제거 하고 실행하면 결과가 조금 달라지긴 하지만
검색어가 없는 경우는 여전히 나옵니다.

SELECT president, speech_date,
    ts_headline(speech_text, to_tsquery('transportation & !roads'),
                'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@
    to_tsquery('english', 'transportation & !roads')
ORDER BY speech_date;
