# Number normalization server

Cấu trúc chương trình
```
Number_Stuff_App -> Number_stuff_sup -> number_stuff_handler
```
Cấu trúc thư mục
- bin: chứa các file thực thi
- include: chứa file header,config
- io: chứa các file input,output
- src: chưa source code của chương trình 

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
    cd /path/to/bin %% Chuyển working directory thi tới thư mục bin
    .\built.bat     %% Complie các file .erl ở thư mục source thành các file
                    %% thực thi .beam ở thư mục bin.
```

## Thực thi chương trình
Mở erlang shell và chạy các lệnh sau: 
```$xslt
    cd("/path/to/bin") %% Chuyển working directory tới thư mục bin. 
    application:start(number_stuff). %% Khởi động ứng dụng.
    test:do("tel/sip-url")           %% Chuẩn hóa từng URL VD: test:do("sip:00842838830408")
    test:stress(N)                   %% Với N là số lần lặp lại các bộ test case 
                                     %% có trong file input.txt
```

Kết quả trả về của hàm test:do hay test:stress là thời gian thực thi và kết quả chuẩn 
hóa tương ứng.

    
        