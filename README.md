# Number normalization server

Cấu trúc chương trình
```
Number_Stuff_App -> Number_stuff_sup -> number_stuff_handler
```
Cấu trúc thư mục
- bin: chứa các file thực thi
- include: chứa file header,config
- io: chứa các file input,output
- src: chứa source code của chương trình 

## Config file
- Chương trình sử dụng file config.json để mô tả các quy tắc chuẩn hóa số điện thoại
gồm có các trường cơ bản như sau: 
    - Các quy định chung: 
        - debug = false/true: Tắt/bật in log.
        - local-cc: mã nước, mặc định là 84
        - num-len: độ dài số điện thoại chuẩn hóa, mặc định là 7
        - max-num-len: độ dài tối đa của số điện thoại được phép, mặc định là 15
        - ac-fixed: Mã điện thoại cố định, mặc định là 3
        - ac-mobile: Mã điện thoại di động, mặc định là 2
    - Normal Rules (normal): Các quy định về đầu số gọi trong nước, ví dụ 283 là đầu số 
   điện thoại ở Hồ Chí Minh, 98 là đầu số của mạng Viettel
    - Special Rules (special): Các quy định đặc biệt khác, ví dụ số gọi quốc tế, số tổng đài, các 
    số gọi khẩn cấp ...
    
## Build chương trình
```$xslt
    %% Chuyển working directory thi tới thư mục bin
    cd /path/to/number_normalization/bin 
    .\built.bat     %% Complie các file .erl ở thư mục source thành các file
                    %% thực thi .beam ở thư mục bin.
```

## Thực thi chương trình
```$xslt
    %% Chuyển working directory tới thư mục bin. 
    cd /path/to/number_normalization/bin      
    %% Khởi động erlang shell và ứng dụng.
    erl -name rilt@127.0.0.1 -setcookie rilt  -eval "application:start(number_stuff)"

    %% Chuẩn hóa từng URL VD: test:do("sip:00842838830408")          
    test:do("tel/sip-url", call/cast)
    %% Chuẩn hóa nhiều URL, với N là số lần lặp lại 
    %% các bộ test case có trong file input.txt     
    test:stress(N, call/cast)                   
                                            
```

## Performace test 
Tiến hành kiểm thử chương trình với test case là 1 tập input.txt gồm 100 URL Sip/tel hỗn hợp và lặp đi lặp lại 
tập trên trên máy Window 7, Core i3 7100, 8Gb Ram.
  Kết quả kiểm thử như sau (Thời gian tính bằng mili giây):

| Số lượng testcase | Thời gian thực thi (Call) | Request/Giây (Call) | Thời gian thực thi (Cast) | Request/Giây (Cast) |
|-------------------|---------------------------|---------------------|---------------------------|---------------------|
|       10000       |          342,995          |        29155        |          373,992          |        26738        |
|       100000      |          3228,930         |        30970        |          4819,896         |        20747        |
|      1000000      |         3168,2927         |        31562        |         33711,045         |        29663        |