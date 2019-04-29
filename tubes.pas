unit tubes;


interface
    const
    durasiPengembalian = 7;

    var
    current_user : string;

    type
    tanggal = record
        dd : integer;
        mm : integer;
        yyyy : integer;
    end;

    buku = record
        id_book : string;
        judul : string;
        pengarang : string;
        jumlah : integer;
        tahun : integer;
        kategori : string;
    end;

    user = record
        nama : string;
        alamat : string;
        username : string;
        password : string;
        role : char;
    end;

    pinjam = record
        username : string;
        id_book : string;
        tglpinjam : tanggal;
        tglkembali : tanggal;
        status : string;
    end;

    hilang = record
        username : string;
        id_book : string;
        tgl : tanggal;
    end;

    kembali = record
        username : string;
        id_book : string;
        tgl : tanggal;
    end;

    recbuku  = record
        tab : array [1..1000] of buku;
        Neff : integer;
    end;

    recuser = record
        tab : array [1..1000] of user;
        Neff : integer;
    end;
    
    recpinjam = record
        tab : array[1..1000] of pinjam;
        Neff : integer;
    end;

    reckembali = record
        tab : array [1..1000] of kembali;
        Neff : integer;
    end;

    rechilang = record
        tab : array [1..1000] of hilang;
        Neff : integer;
    end;


    var
    a : integer;

    procedure cariTahunTerbit(arrayname: recbuku);
    procedure cariKategori(arrayname : recbuku);
    function login(arrayname : recuser): Char;
    procedure registrasi(var arrayname : recuser);
    procedure tambahbuku(var arrayname : recbuku);
    procedure tambahjumlahbuku(var arrayname : recbuku);
    procedure riwayat(var arrayname : recPinjam;arrayname2: recbuku);
    function buku_apa(arrayname : recbuku; id_terinput : string) : string;
    procedure statistik(arrayname :recuser; arrayname2 : recbuku);
    function jumlah_siapa(arrayname : recuser; dicari : char) : integer;
    function statistik_buku(arrayname : recbuku; dicari : string): integer;
    procedure cari_anggota(arrayname : recuser);


    function parsingUser(filename: string) : recuser;
    procedure saveUser(var recUserTemp: recuser; filename:string);

    function parsingBuku(filename: string) : recbuku;
    procedure saveBuku(var recBukuTemp : recbuku; filename: string);
 
    function parsingPinjam(filename: string) : recPinjam; // Memparse data pinjam
    procedure savePinjam(var recPinjamTemp : recPinjam; filename: string); // Mensave data pinjam

    function parsingHilang(filename: string) : recHilang;
    procedure saveHilang(var recHilangTemp : recHilang; filename: string);
 
    function parsingKembali(filename: string) : recKembali;
    procedure saveKembali(var recKembaliTemp : recKembali; filename: string);

    procedure lapor_hilang(var arrayname : rechilang);
    function find_index_buku(recBukuTemp : recbuku; idbuku : string) : integer;
    function tanggal_kembali(tanggalPinjam : string):tanggal;
    function find_pinjam(recPinjamTemp : recpinjam; username: string; id_buku : string):integer;
    procedure pinjam_buku(var recBukuTemp : recbuku; var recPinjamTemp : recpinjam);
    function selisih_hari(tanggal_pinjam : tanggal; tanggal_kembali : tanggal) : integer;
    procedure kembalikan_buku(var recBukuTemp : recbuku; var recPinjamTemp : recpinjam; var recKembaliTemp : reckembali);
    procedure lihat_laporan(recHilangTemp : rechilang; recBukuTemp : recbuku);

implementation
    procedure registrasi(var arrayname : recuser);
        { Melakukan registrasi user baru;
          I.S. : Sudah log in sebagai admin; 
          F.S. : User baru terdaftar sebagai pengunjung}
        
        {KAMUS LOKAL}
        var
            nama,alamat,username,password : string;
        {ALGORITMA}
        begin
            //memasukkan input dari user
            write('Masukkan nama pengunjung: ');
            readln(nama);
            write('Masukkkan alamat pengunjung: ');
            readln(alamat);
            write('Masukkkan username pengunjung: ');
            readln(username);
            write('Masukkkan password pengunjung: ');
            readln(password);

            //menambahkan data ke array user dan menambah neff
            inc(arrayname.neff);
            arrayname.tab[arrayname.neff].nama := nama;
            arrayname.tab[arrayname.neff].alamat := alamat;
            arrayname.tab[arrayname.neff].username := username;
            arrayname.tab[arrayname.neff].password := password;
            arrayname.tab[arrayname.neff].role := 'N';

            //menuliskan pesan konfirmasi
            writeln('Pengunjung ',nama,' berhasil terdaftar sebagai user.')
        end;

    function login(arrayname : recuser): Char;
        { Melakukan login untuk user;
        I.S. : user belum log in;
        F.s. : login = 'A' jika admin,
                login = 'N' jika bukan admin,
                login = 'W' jika tidak terdaftar sebagai user
        }

        {KAMUS LOKAL}
        var
            username : string;
            password : string;
            found   : boolean;
            i       : integer;

        {ALGORTIMA}
        begin
            //input user
            write('Masukkan username: ');
            readln(username);
            write('Masukkan password: ');
            readln(password);

            //validasi user dan password
            found := False;
            i := 1;
            repeat
                if (arrayname.tab[i].username = username) and (arrayname.tab[i].password = password) then
                begin
                    found := True;
                end;
                i := i + 1;
            until (found) or (i > arrayname.Neff);

            if found then
            begin
                if (arrayname.tab[i-1].role = 'Y') then
                begin
                    login := 'A'; // User adalah admin
                end else 
                begin
                    login := 'N'; // User adalah pengunjung
                end;
                writeln('Selamat Datang ', arrayname.tab[i-1].nama,'!');
                current_user := arrayname.tab[i-1].username;
            end else
            begin
                login := 'W'; // User tidak terdaftar
                writeln('Username / password salah! Silakan coba lagi');
            end
        end;

    procedure cariTahunTerbit(arrayname: recbuku);
        {Mencari buku berdasarkan tahun terbit
         I.S. : User sudah log in;
         F.S. : Buku ditampilkan dengan format:
                id_buku | judul | pengarang
                secara terurut berdasarkan judul buku
        }

        {KAMUS LOKAL}
        var
            counter : integer;
            tahun : integer;
            tanda : string;
        
        {ALGORITMA}
        begin
            counter := 0;
            write('Masukkan tahun: ');
            readln(tahun);
            write('Masukkan kategori: ');
            readln(tanda);
                for a:= 1 to arrayname.Neff do
                begin
                    if (tanda = '<') then
                    begin
                        if (arrayname.tab[a].tahun < tahun) then
                            begin
                                counter := counter + 1;
                                write(arrayname.tab[a].id_book, ' | ',arrayname.tab[a].judul, ' | ', arrayname.tab[a].pengarang);
                                writeln();
                            end;
                    end else if (tanda = '>') then
                    begin
                        if (arrayname.tab[a].tahun > tahun) then
                            begin
                                counter := counter + 1;
                                write(arrayname.tab[a].id_book, ' | ',arrayname.tab[a].judul, ' | ', arrayname.tab[a].pengarang);
                                writeln();
                            end;
                    end else if (tanda = '=') then
                    begin
                        if (arrayname.tab[a].tahun = tahun) then
                            begin
                                counter := counter + 1;
                                write(arrayname.tab[a].id_book, ' | ',arrayname.tab[a].judul, ' | ', arrayname.tab[a].pengarang);
                                writeln();
                            end;
                    end else if (tanda = '>=') then
                    begin
                        if (arrayname.tab[a].tahun >= tahun) then
                            begin
                                counter := counter + 1;
                                write(arrayname.tab[a].id_book, ' | ',arrayname.tab[a].judul, ' | ', arrayname.tab[a].pengarang);
                                writeln();
                            end;
                    end else if (tanda = '<=') then
                    begin
                        if (arrayname.tab[a].tahun <=  tahun) then
                            begin
                                counter := counter + 1;
                                write(arrayname.tab[a].id_book, ' | ',arrayname.tab[a].judul, ' | ', arrayname.tab[a].pengarang);
                                writeln();
                            end;
                    end;
                end;    
                if (counter = 0) then
                begin
                    writeln('Tidak ada buku dalam kategori ini.');
                end;
        end;

    function jumlah_siapa(arrayname : recuser; dicari : char) : integer;
        { menghitung banyaknya orang
          I.S. : tersedia array yang berisi data user
          F.S. : jumlah_siapa = banyaknya role yang dicari
        }

        {KAMUS LOKAL}
        var
            banyak_orang : integer;
            i : integer;

        {ALGORITMA}    
        begin
            banyak_orang := 0;
            for i := 1 to arrayname.Neff do
                begin
                    if (arrayname.tab[i].role = dicari) then
                        begin
                            banyak_orang := banyak_orang + 1;
                        end;
                end;
            jumlah_siapa := banyak_orang;
        end;

    function statistik_buku(arrayname : recbuku; dicari : string): integer;
        { Menghitung banyaknya jumlah buku berdasarkan kategori
          I.S. : terdapat array yang berisi data bertipe buku;
          F.S. : statistik_buku = jumlah buku berdasarkan kategori yang dicari
        }

        {KAMUS LOKAL}
        var
            banyak_buku : integer;
            i : integer;

        {ALGORITMA}    
        begin
            banyak_buku := 0;
            for i := 1 to arrayname.Neff do
                begin
                    if (arrayname.tab[i].kategori = dicari) then
                        begin
                            banyak_buku := banyak_buku + arrayname.tab[i].jumlah;
                        end;
                end;
            statistik_buku := banyak_buku;
        end;

    procedure statistik(arrayname : recuser; arrayname2 : recbuku);
        { Menuliskan statistik jumlah user berdasarkan role dan jumlah buku berdasarkan kategori
        I.S. : Terdapat fungsi yang mencari banyaknya buku atau user yang ingin dicari
        F.S. : Mencetak statistik user dan buku 
        }

        {ALGORITMA}
        begin
            writeln('Pengguna:');
            write('Admin | ');
            writeln(jumlah_siapa(arrayname, 'Y'));
            write('Pengunjung | ');
            writeln(jumlah_siapa(arrayname, 'N'));
            write('Total | ');
            writeln(jumlah_siapa(arrayname,  'Y') + jumlah_siapa(arrayname, 'N'));
            writeln('Buku:');
            write('sastra | ');
            writeln(statistik_buku(arrayname2, 'sastra'));
            write('sains | ');
            writeln(statistik_buku(arrayname2, 'sains'));
            write('manga | ');
            writeln(statistik_buku(arrayname2, 'manga'));
            write('sejarah | ');
            writeln(statistik_buku(arrayname2, 'sejarah'));
            write('programming | ');
            writeln(statistik_buku(arrayname2, 'programming'));
            write('Total | ');
            writeln(statistik_buku(arrayname2, 'sastra') + statistik_buku(arrayname2, 'sains') + statistik_buku(arrayname2, 'manga') + statistik_buku(arrayname2, 'sejarah') + statistik_buku(arrayname2, 'programming') );   
        end;

    procedure tambahbuku(var arrayname : recbuku);
        var 
            idbuku, judul, pengarang, kategori: string;
            jumlah, tahun : integer;
        begin 
            writeln('Masukkan Informasi buku yang ditambahkan:');
            write('Masukkan Id buku: ');
            readln(idbuku);
            write('Masukkan judul buku: ');
            readln(judul);
            write('Masukkan pengarang buku: ');
            readln(pengarang);
            write('Masukkan jumlah buku: ');
            readln(jumlah);
            write('Masukkan tahun terbit buku: ');
            readln(tahun);
            write('Masukkan kategori buku: ');
            readln(kategori);

            inc(arrayname.neff);
            arrayname.tab[arrayname.neff].id_book := idbuku;
            arrayname.tab[arrayname.neff].judul := judul;
            arrayname.tab[arrayname.neff].pengarang := pengarang;
            arrayname.tab[arrayname.neff].jumlah := jumlah;
            arrayname.tab[arrayname.neff].tahun := tahun;
            arrayname.tab[arrayname.neff].kategori := kategori ;


            writeln();
            writeln('Buku berhasil ditambahkan ke dalam sistem');
        end;

    function buku_apa(arrayname : recbuku; id_terinput : string) : string;
        var
            j : integer;
            found : boolean;
            jawaban : string;       
        begin
            j := 1;
            found := False;
            while (j <= arrayname.Neff) and (found = False) do
                begin
                    if (arrayname.tab[j].id_book = id_terinput) then
                        begin
                            jawaban := arrayname.tab[j].judul;
                            found := True;
                        end
                    else
                        begin
                            j := j + 1;
                        end;
                end;
            buku_apa := jawaban;
        end;

    procedure riwayat(var arrayname : recPinjam;arrayname2: recbuku); //diasumsikan username sudah valid
        var
            nama_user : string;
            i : integer;
        begin 
            write('Masukkan username pengunjung: ');
            readln(nama_user);
            for i:= 1 to arrayname.Neff do
                begin
                    if (arrayname.tab[i].username = nama_user) then
                        begin
                            writeln(arrayname.tab[i].tglkembali.dd , '/' , arrayname.tab[i].tglkembali.mm , '/' , arrayname.tab[i].tglkembali.yyyy , ' | ' , arrayname.tab[i].id_book , ' | ' , buku_apa(arrayname2, arrayname2.tab[i].id_book));  
                        end;
                end;
        end;

    procedure tambahjumlahbuku(var arrayname : recbuku);
        var 
            idbuku : string;
            tambah, index : integer;
            found : boolean;
        begin 
            write('Masukkan ID buku: ');
            read(idbuku);
            write('Masukkan jumlah buku yang ditambahkan: ');
            read(tambah);

            found := False;
            index := 1;
            repeat
                if (arrayname.tab[index].id_book = idbuku) then
                begin
                    found := True;
                end else
                begin
                    inc(index);
                end;
            until found;

            arrayname.tab[index].jumlah := arrayname.tab[index].jumlah + tambah;

            writeln();
            writeln('Pembaharuan jumlah buku berhasil dilakkukan, total buku ',arrayname.tab[index].judul,' di perpustakaan menjadi ',arrayname.tab[index].jumlah);
        end;

    procedure cariKategori(arrayname : recbuku);
        var
            cat : string;
            stop : boolean;
            counter : integer;
        begin
            stop := False;
            counter := 0;

             //validasi input
            repeat
            write('Masukkan kategori: ');
            readln(cat);
            if (cat = 'programming') or (cat = 'sains') or (cat = 'manga') or (cat = 'sejarah') or (cat = 'sastra') then
            begin
                stop := true;    
            end else
            begin
                writeln('kategori ',cat,' tidak valid');
            end;
            until stop;

            for a:= 1 to arrayname.Neff do
            begin
                if (arrayname.tab[a].kategori = cat) and (arrayname.tab[a].jumlah > 0)  then
                begin
                    write(arrayname.tab[a].id_book,' | ',arrayname.tab[a].judul, ' | ', arrayname.tab[a].pengarang);
                    writeln();
                    counter := counter + 1;
                end;
            end;
            if (counter = 0) then
            begin
                writeln('Tidak ada buku dalam kategori ini.');
            end;
        end;
    
    function parsingUser(filename: string) : recuser;
        var
            recUserTemp : recuser;
            Userfile : Text;
            readchar : char;
            lenRecorded :longint;
            row, column : integer;
            enterCounter : integer;
        begin
            recUserTemp.Neff := 0;        

            // Baca file sampai panjang file terbaca melebihi panjang file sesungguhnya
            enterCounter := 0;
            assign(Userfile, filename);
            row := 1 ; column := 1; lenRecorded:= 1; 
            reset(Userfile);
            read(Userfile, readchar);
            while (not eof(Userfile)) do
            begin
                while (readchar <> ',') do
                begin
                    if (readchar <> #13) and (readchar <> #10) and (readchar <> #13#10) then
                    begin
                        if (column mod 5 = 1) then
                        begin
                            recUserTemp.tab[row].nama := recUserTemp.tab[row].nama + readchar;
                            read(Userfile, readchar);
                            lenRecorded := lenRecorded + 1;
                        end else if (column mod 5 = 2) then
                        begin
                            recUserTemp.tab[row].alamat := recUserTemp.tab[row].alamat + readchar;
                            read(Userfile, readchar);
                            lenRecorded := lenRecorded + 1;
                        end else if (column mod 5 = 3) then
                        begin
                            recUserTemp.tab[row].username := recUserTemp.tab[row].username + readchar;
                            read(Userfile, readchar);
                            lenRecorded := lenRecorded + 1;
                        end else if (column mod 5 = 4) then
                        begin
                            recUserTemp.tab[row].password := recUserTemp.tab[row].password + readchar;
                            read(Userfile, readchar);
                            lenRecorded := lenRecorded + 1;
                        end else if (column mod 5 = 0) then
                        begin
                            recUserTemp.tab[row].role := readchar;
                            read(Userfile, readchar);
                            lenRecorded := lenRecorded + 1;
                        end;
                    end else begin
                        break;
                    end;
                end;

                if (readchar = ',') then
                begin
                    column := column + 1;
                    read(Userfile, readchar);
                end;

                if (readchar = #13) or (readchar = #10) or (readchar = #13#10) then
                begin
                    if (enterCounter = 0) then
                    begin
                        recUserTemp.Neff := recUserTemp.Neff + 1;
                        row := row + 1;
                        enterCounter := 1;
                        column := 1;
                        read(Userfile, readchar);
                        lenRecorded := lenRecorded + 1;    
                    end else begin
                        enterCounter := 0;
                        column := 1;
                        read(Userfile, readchar);
                        lenRecorded := lenRecorded + 1;
                    end;
                end;
            end;
            parsingUser := recUserTemp;
            Close(Userfile);
        end;
    
    procedure saveUser(var recUserTemp : recuser; filename: string);
        var
            i   : integer;
            fileUserLen : integer;
            UserfileOut : Text;
        begin
            assign(UserfileOut, filename);
            rewrite(userfileOut);
            fileUserLen := recUserTemp.Neff;
            for i:= 1 to recUserTemp.Neff-1 do
            begin
                writeln(UserfileOut, recUserTemp.tab[i].nama + ',' + recUserTemp.tab[i].alamat + ',' + recUserTemp.tab[i].username + ',' + recUserTemp.tab[i].password + ',' + recUserTemp.tab[i].role);
            end;
            writeln(UserfileOut, recUserTemp.tab[fileUserLen].nama + ',' + recUserTemp.tab[fileUserLen].alamat + ',' + recUserTemp.tab[fileUserLen].username + ',' + recUserTemp.tab[fileUserLen].password + ',' + recUserTemp.tab[fileUserLen].role);
            close(userfileOut);
        end;

    function parsingBuku(filename: string) : recbuku;
        var
            recBukuTemp : recbuku;
            Bukufile : Text;
            F : file of char;
            readchar : char;
            lenRecorded :longint;
            row, column : integer;
            enterCounter : integer;
            tempJumlah, tempTahun : string; // String sementara dari pembacaan csv
        begin
            // Setup
            tempJumlah := ''; tempTahun := '';
            recBukuTemp.Neff := 0;
            // Cari panjang file
            assign(F, filename);
            reset(F);
            close(F);

            // Baca file sampai panjang file terbaca melebihi panjang file sesungguhnya
            enterCounter := 0;
            assign(Bukufile, filename);
            row := 1 ; column := 1; lenRecorded:= 1; 
            reset(Bukufile);
            read(Bukufile, readchar);
            while (not (eof(Bukufile))) do
            begin
                while (readchar <> ',') do
                begin
                    if (readchar <> #13) and (readchar <> #10) and (readchar <> #13#10) then
                    begin
                        if (column mod 6 = 1) then
                        begin
                            recBukuTemp.tab[row].id_book := recBukuTemp.tab[row].id_book + readchar;
                            read(Bukufile, readchar);
                        end else if (column mod 6 = 2) then
                        begin
                            recBukuTemp.tab[row].judul := recBukuTemp.tab[row].judul + readchar;
                            read(Bukufile, readchar);
                        end else if (column mod 6 = 3) then
                        begin
                            recBukuTemp.tab[row].pengarang := recBukuTemp.tab[row].pengarang + readchar;
                            read(Bukufile, readchar);
                        end else if (column mod 6 = 4) then
                        begin
                            tempJumlah := tempJumlah + readchar;
                            // recBukuTemp.tab[row].jumlah := recBukuTemp.tab[row].jumlah + readchar;
                            read(Bukufile, readchar);
                        end else if (column mod 6 = 5) then
                        begin
                            tempTahun := tempTahun + readchar;
                            // recBukuTemp.tab[row].tahun := tahun;
                            read(Bukufile, readchar);
                        end else if (column mod 6 = 0) then
                        begin
                            recBukuTemp.tab[row].kategori := recBukuTemp.tab[row].kategori + readchar;
                            read(Bukufile, readchar);
                        end;
                    end else begin
                        break;
                    end;
                end;

                if (readchar = ',') then
                begin
                    column := column + 1;
                    read(Bukufile, readchar);
                    lenRecorded := lenRecorded + 1;
                end;

                if (readchar = #13) or (readchar = #10) or (readchar = #13#10) then
                begin
                    if (enterCounter = 0) then
                    begin
                        val(tempJumlah, recBukuTemp.tab[row].jumlah);
                        val(tempTahun, recBukuTemp.tab[row].tahun);
                        tempJumlah := '';
                        tempTahun := '';
                        recBukuTemp.Neff := recBukuTemp.Neff + 1;
                        row := row + 1;
                        enterCounter := 1;
                        column := 1;
                        read(Bukufile, readchar);
                        lenRecorded := lenRecorded + 1;    
                    end else begin
                        enterCounter := 0;
                        column := 1;
                        read(Bukufile, readchar);
                        lenRecorded := lenRecorded + 1;
                    end;
                end;
            end;
            parsingBuku := recBukuTemp;
            close(Bukufile);
        end;

    procedure saveBuku(var recBukuTemp : recbuku; filename: string);
        var
            i   : integer;
            fileBukuLen : integer;
            BukufileOut : Text;
            jumlahStr, tahunStr : string;
        begin
            assign(BukufileOut, filename);
            rewrite(BukufileOut);
            fileBukuLen := recBukuTemp.Neff;
            for i:= 1 to recBukuTemp.Neff-1 do
            begin
                str(recBukuTemp.tab[i].jumlah, jumlahStr);
                str(recBukuTemp.tab[i].tahun, tahunStr);
                writeln(BukufileOut, recBukuTemp.tab[i].id_book + ',' + recBukuTemp.tab[i].judul + ',' + recBukuTemp.tab[i].pengarang + ',' + jumlahStr + ',' + tahunStr + ',' + recBukuTemp.tab[i].kategori);
            end;
            str(recBukuTemp.tab[fileBukuLen].jumlah, jumlahStr);
            str(recBukuTemp.tab[fileBukuLen].tahun, tahunStr);
            writeln(BukufileOut, recBukuTemp.tab[fileBukuLen].id_book + ',' + recBukuTemp.tab[fileBukuLen].judul + ',' + recBukuTemp.tab[fileBukuLen].pengarang + ',' + jumlahStr + ',' + tahunStr + ',' + recBukuTemp.tab[fileBukuLen].kategori);
            // writeln(BukufileOut, '6969696,BukuSaveTest,PengarangSaveTest,6,9,Sastra'); ~~~ BUAT TESTING ~~~
            close(BukufileOut);
        end;

    function parsingPinjam(filename: string) : recPinjam;
        var
            tanggalTemp : string;
            recPinjamTemp : recPinjam;
            Pinjamfile : Text;
            readchar : char;
            row, column : integer;
            enterCounter : integer;
        begin
            // Setup
            tanggalTemp := '';
            recPinjamTemp.Neff := 0;

            // Baca file sampai panjang file terbaca melebihi panjang file sesungguhnya
            enterCounter := 0;
            assign(Pinjamfile, filename);
            row := 1 ; column := 1;
            reset(Pinjamfile);
            read(Pinjamfile, readchar);
            while (not (eof(Pinjamfile))) do
            begin
                while (readchar <> ',') do
                begin
                    if (readchar <> #13) and (readchar <> #10) and (readchar <> #13#10) then
                    begin
                        if (column mod 5 = 1) then
                        begin
                            recPinjamTemp.tab[row].Username := recPinjamTemp.tab[row].Username + readchar;
                            read(Pinjamfile, readchar);
                        end else if (column mod 5 = 2) then
                        begin
                            recPinjamTemp.tab[row].id_book := recPinjamTemp.tab[row].id_book + readchar;
                            read(Pinjamfile, readchar);
                        end else if (column mod 5 = 3) then
                        begin
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            val(tanggalTemp, recPinjamTemp.tab[row].tglpinjam.dd);
                            tanggalTemp := '';

                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            val(tanggalTemp, recPinjamTemp.tab[row].tglpinjam.mm);
                            tanggalTemp := '';

                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            val(tanggalTemp, recPinjamTemp.tab[row].tglpinjam.yyyy);
                            tanggalTemp  := '';
                            read(Pinjamfile, readchar);
                        end else if (column mod 5 = 4) then
                        begin
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            val(tanggalTemp, recPinjamTemp.tab[row].tglkembali.dd);
                            tanggalTemp := '';

                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            val(tanggalTemp, recPinjamTemp.tab[row].tglkembali.mm);
                            tanggalTemp := '';

                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Pinjamfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            val(tanggalTemp, recPinjamTemp.tab[row].tglkembali.yyyy);
                            tanggalTemp  := '';
                            read(Pinjamfile, readchar);
                        end else if (column mod 5 = 0) then
                        begin
                            recPinjamTemp.tab[row].status := recPinjamTemp.tab[row].status + readchar;
                            read(Pinjamfile, readchar);
                        end;
                    end else begin
                        break;
                    end;
                end;

                if (readchar = ',') then
                begin
                    column := column + 1;
                    read(Pinjamfile, readchar);
                end;

                if (readchar = #13) or (readchar = #10) or (readchar = #13#10) then
                begin
                    if (enterCounter = 0) then
                    begin
                        recPinjamTemp.Neff := recPinjamTemp.Neff + 1;
                        row := row + 1;
                        enterCounter := 1;
                        column := 1;
                        read(Pinjamfile, readchar);
                    end else begin
                        enterCounter := 0;
                        column := 1;
                        read(Pinjamfile, readchar);
                    end;
                end;
            end;
            close(Pinjamfile);
            parsingPinjam := recPinjamTemp;
        end;

    procedure savePinjam(var recPinjamTemp : recPinjam; filename: string);
        var
            i   : integer;
            PinjamfileOut : Text;
            hariPinStr, bulanPinStr, tahunPinStr, hariKemStr, bulanKemStr, tahunKemStr: string; // Masing-masing hari, bulan, dan tahun pada peminjaman dan pengembalian buku dalam string
            tanggalPinTemp : string; // Tanggal peminjaman dalam string, siap dimasukkan ke file csv
            tanggalKemTemp : string; // Tanggal pengembalian dalam string, siap dimasukkan ke file csv
        begin
            assign(PinjamfileOut, filename);
            rewrite(PinjamfileOut);
            for i:= 1 to recPinjamTemp.Neff do
            begin
                if (recPinjamTemp.tab[i].tglpinjam.mm < 10) then // Cek apakah bulan peminjaman kurang dari 10. Jika ya, tambahkan char '0' didepan
                begin
                    str(recPinjamTemp.tab[i].tglpinjam.mm, bulanPinStr);
                    bulanPinStr := '0' + bulanPinStr;  
                end else
                begin
                    str(recPinjamTemp.tab[i].tglpinjam.mm, bulanPinStr);
                end;
                str(recPinjamTemp.tab[i].tglpinjam.dd, hariPinStr);
                str(recPinjamTemp.tab[i].tglpinjam.yyyy, tahunPinStr);

                if (recPinjamTemp.tab[i].tglkembali.mm < 10) then // Cek apakah bulan pengembalian kurang dari 10. Jika ya, tambahkan char '0' didepan
                begin
                    str(recPinjamTemp.tab[i].tglkembali.mm, bulanKemStr);
                    bulanKemStr := '0' + bulanKemStr;  
                end else
                begin
                    str(recPinjamTemp.tab[i].tglkembali.mm, bulanKemStr);
                end;
                str(recPinjamTemp.tab[i].tglkembali.dd, hariKemStr);
                str(recPinjamTemp.tab[i].tglkembali.yyyy, tahunKemStr);

                tanggalPinTemp := hariPinStr + '/' + bulanPinStr + '/' + tahunPinStr;
                tanggalKemTemp := hariKemStr + '/' + bulanKemStr + '/' + tahunKemStr;

                writeln(PinjamfileOut, recPinjamTemp.tab[i].username+','+recPinjamTemp.tab[i].id_book+','+tanggalPinTemp+','+tanggalKemTemp+','+recPinjamTemp.tab[i].status);
            end;
            // writeln(PinjamfileOut, 'fabianzagain,1231233,13/07/2000,13/08/2000,sudah'); // ~~~ BUAT TESTING ~~~
            close(PinjamfileOut);
        end;

    function parsingHilang(filename: string) : recHilang;
        var
            tanggalTemp : string;
            recHilangTemp : recHilang;
            Hilangfile : Text;
            readchar : char;
            row, column : integer;
            enterCounter : integer;
        begin
            // Setup
            tanggalTemp := '';
            recHilangTemp.Neff := 0;

            // Baca file sampai panjang file terbaca melebihi panjang file sesungguhnya
            enterCounter := 0;
            assign(Hilangfile, filename);
            row := 1 ; column := 1;
            reset(Hilangfile);
            read(Hilangfile, readchar);
            while (not (eof(Hilangfile))) do
            begin
                while (readchar <> ',') do
                begin
                    if (readchar <> #13) and (readchar <> #10) and (readchar <> #13#10) then
                    begin
                        if (column mod 3 = 1) then
                        begin
                            recHilangTemp.tab[row].Username := recHilangTemp.tab[row].Username + readchar;
                            read(Hilangfile, readchar);
                        end else if (column mod 3 = 2) then
                        begin
                            recHilangTemp.tab[row].id_book := recHilangTemp.tab[row].id_book + readchar;
                            read(Hilangfile, readchar);
                        end else if (column mod 3 = 0) then
                        begin
                            tanggalTemp := tanggalTemp + readchar;
                            read(Hilangfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Hilangfile, readchar);
                            val(tanggalTemp, recHilangTemp.tab[row].tgl.dd);
                            tanggalTemp := '';

                            read(Hilangfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Hilangfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Hilangfile, readchar);
                            val(tanggalTemp, recHilangTemp.tab[row].tgl.mm);
                            tanggalTemp := '';

                            read(Hilangfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Hilangfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Hilangfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Hilangfile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            val(tanggalTemp, recHilangTemp.tab[row].tgl.yyyy);
                            tanggalTemp  := '';
                            read(Hilangfile, readchar);
                        end;
                    end else begin
                        break;
                    end;
                end;

                if (readchar = ',') then
                begin
                    column := column + 1;
                    read(Hilangfile, readchar);
                end;

                if (readchar = #13) or (readchar = #10) or (readchar = #13#10) then
                begin
                    if (enterCounter = 0) then
                    begin
                        recHilangTemp.Neff := recHilangTemp.Neff + 1;
                        row := row + 1;
                        enterCounter := 1;
                        column := 1;
                        read(Hilangfile, readchar);
                    end else begin
                        enterCounter := 0;
                        column := 1;
                        read(Hilangfile, readchar);
                    end;
                end;
            end;
            close(Hilangfile);
            parsingHilang := recHilangTemp;
        end;


    procedure saveHilang(var recHilangTemp : recHilang; filename: string);
        var
            i   : integer;
            HilangfileOut : Text;
            hariStr, bulanStr, tahunStr: string;
        begin
            assign(HilangfileOut, filename);
            rewrite(HilangfileOut);
            for i:= 1 to recHilangTemp.Neff do
            begin
                if (recHilangTemp.tab[i].tgl.mm < 10) then
                begin
                    str(recHilangTemp.tab[i].tgl.mm, bulanStr);
                    bulanStr := '0' + bulanStr;  
                end else
                begin
                    str(recHilangTemp.tab[i].tgl.mm, bulanStr);
                end;
                str(recHilangTemp.tab[i].tgl.dd, hariStr);
                str(recHilangTemp.tab[i].tgl.yyyy, tahunStr);
                writeln(HilangfileOut, recHilangTemp.tab[i].username+','+recHilangTemp.tab[i].id_book+','+hariStr+'/'+bulanStr+'/'+tahunStr);
            end;
            // writeln(HilangfileOut, 'fabianz,1231233,13/07/2000'); // ~~~ BUAT TESTING ~~~
            close(HilangfileOut);
        end;

    function parsingKembali(filename: string) : recKembali;
        var
            tanggalTemp : string;
            recKembaliTemp : recKembali;
            Kembalifile : Text;
            readchar : char;
            row, column : integer;
            enterCounter : integer;
        begin
            // Setup
            tanggalTemp := '';
            recKembaliTemp.Neff := 0;

            // Baca file sampai panjang file terbaca melebihi panjang file sesungguhnya
            enterCounter := 0;
            assign(Kembalifile, filename);
            row := 1 ; column := 1;
            reset(Kembalifile);
            read(Kembalifile, readchar);
            while (not (eof(Kembalifile))) do
            begin
                while (readchar <> ',') do
                begin
                    if (readchar <> #13) and (readchar <> #10) and (readchar <> #13#10) then
                    begin
                        if (column mod 3 = 1) then
                        begin
                            recKembaliTemp.tab[row].Username := recKembaliTemp.tab[row].Username + readchar;
                            read(Kembalifile, readchar);
                        end else if (column mod 3 = 2) then
                        begin
                            recKembaliTemp.tab[row].id_book := recKembaliTemp.tab[row].id_book + readchar;
                            read(Kembalifile, readchar);
                        end else if (column mod 3 = 0) then
                        begin
                            tanggalTemp := tanggalTemp + readchar;
                            read(Kembalifile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Kembalifile, readchar);
                            val(tanggalTemp, recKembaliTemp.tab[row].tgl.dd);
                            tanggalTemp := '';

                            read(Kembalifile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Kembalifile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Kembalifile, readchar);
                            val(tanggalTemp, recKembaliTemp.tab[row].tgl.mm);
                            tanggalTemp := '';

                            read(Kembalifile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Kembalifile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Kembalifile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            read(Kembalifile, readchar);
                            tanggalTemp := tanggalTemp + readchar;
                            val(tanggalTemp, recKembaliTemp.tab[row].tgl.yyyy);
                            tanggalTemp  := '';
                            read(Kembalifile, readchar);
                        end;
                    end else begin
                        break;
                    end;
                end;

                if (readchar = ',') then
                begin
                    column := column + 1;
                    read(Kembalifile, readchar);
                end;

                if (readchar = #13) or (readchar = #10) or (readchar = #13#10) then
                begin
                    if (enterCounter = 0) then
                    begin
                        recKembaliTemp.Neff := recKembaliTemp.Neff + 1;
                        row := row + 1;
                        enterCounter := 1;
                        column := 1;
                        read(Kembalifile, readchar);
                    end else begin
                        enterCounter := 0;
                        column := 1;
                        read(Kembalifile, readchar);
                    end;
                end;
            end;
            close(Kembalifile);
            parsingKembali := recKembaliTemp;
        end;

    procedure saveKembali(var recKembaliTemp : recKembali; filename: string);
        var
            i   : integer;
            KembalifileOut : Text;
            hariStr, bulanStr, tahunStr: string;
        begin
            assign(KembalifileOut, filename);
            rewrite(KembalifileOut);
            for i:= 1 to recKembaliTemp.Neff do
            begin
                if (recKembaliTemp.tab[i].tgl.mm < 10) then
                begin
                    str(recKembaliTemp.tab[i].tgl.mm, bulanStr);
                    bulanStr := '0' + bulanStr;  
                end else
                begin
                    str(recKembaliTemp.tab[i].tgl.mm, bulanStr);
                end;
                str(recKembaliTemp.tab[i].tgl.dd, hariStr);
                str(recKembaliTemp.tab[i].tgl.yyyy, tahunStr);
                writeln(KembalifileOut, recKembaliTemp.tab[i].username+','+recKembaliTemp.tab[i].id_book+','+hariStr+'/'+bulanStr+'/'+tahunStr);
            end;
            close(KembalifileOut);
        end;

    procedure cari_anggota(arrayname : recuser);
        var
            found : boolean;
            i : integer;
            username_terinput : string;    
        begin
            write('Masukkan username: ');
            readln(username_terinput);
            i := 1;
            found := False;
            while (i <= arrayname.Neff) and (found = False) do
                begin
                    if (arrayname.tab[i].username = username_terinput) then
                        begin
                            found := True;
                        end
                    else
                        begin
                            i := i + 1;
                        end
                end;
            if (i > arrayname.Neff) then
                begin
                    writeln('Anggota dengan username tersebut tidak ditemukan');
                end
            else //found = True atau ketemu
                begin
                    write('Nama Anggota: ');
                    writeln(arrayname.tab[i].nama);
                    write('Alamat anggota: ');
                    writeln(arrayname.tab[i].alamat);
                end;
        end;

    procedure lapor_hilang(var arrayname : rechilang);
        var
            id_hilang, tanggal_pelaporan : string;
            day, month, year : string;
        begin
            write('Masukkan id buku : ');
            readln(id_hilang);
            write('Masukkan tanggal pelaporan : ');
            readln(tanggal_pelaporan);
            arrayname.Neff := arrayname.Neff + 1;
            arrayname.tab[arrayname.Neff].username := current_user;
            arrayname.tab[arrayname.Neff].id_book := id_hilang;
            day := copy(tanggal_pelaporan, 1, 2);
            month := copy(tanggal_pelaporan, 4, 2);
            year := copy(tanggal_pelaporan, 7, 4);
            val(day, arrayname.tab[arrayname.Neff].tgl.dd);
            val(month, arrayname.tab[arrayname.Neff].tgl.mm);        
            val(year, arrayname.tab[arrayname.Neff].tgl.yyyy);
            writeln();
            writeln('Laporan berhasil diterima.');
        end;

    function find_index_buku(recBukuTemp : recbuku; idbuku : string) : integer;
        var
            i : integer;
        begin
            i := 1;
            while (i < recBukuTemp.Neff) do
            begin
                if (recBukuTemp.tab[i].id_book = idbuku) then
                begin
                    find_index_buku := i;
                    break;
                end else
                begin
                    i:= i + 1;
                end;
            end;
            if (i > recBukuTemp.Neff) then
            begin
                find_index_buku := -1;
            end;
        end;

    function tanggal_kembali(tanggalPinjam : string):tanggal;
        var
            dayp, monthp, yearp, dayk, monthk, yeark : longint;
            temp : tanggal;
        begin
            val(copy(tanggalPinjam, 1, 2), dayp);
            val(copy(tanggalPinjam, 4, 2), monthp);
            val(copy(tanggalPinjam, 7, 4), yearp);

            if (monthp = 1) or (monthp = 3) or (monthp = 5) or (monthp = 7) or (monthp = 8) or (monthp = 10) or (monthp = 12) then
            begin
                if (dayp + durasiPengembalian > 31) then
                begin
                    if (monthp = 12) then 
                    begin
                        dayk := 1;
                        monthk := 1;
                        yeark:= yearp + 1;
                    end else
                    begin
                        dayk := dayp + durasiPengembalian - 31;
                        monthk := monthp + 1;
                        yeark := yearp;
                    end;
                end else
                begin
                    dayk := dayp + durasiPengembalian;
                    monthk := monthp;
                    yeark := yearp;
                end;
            end else if (monthp = 4) or (monthp = 6) or (monthp = 9) or (monthp = 11) then
            begin
                if (dayp + durasiPengembalian > 30) then
                begin
                    dayk := dayp + durasiPengembalian - 30;
                    monthk := monthp + 1; yeark := yearp;
                end else
                begin
                    dayk := dayp + durasiPengembalian;
                    monthk := monthp; yeark := yearp;
                end;
            end else
            begin
                if (yearp mod 4 = 0) then
                begin
                    if (dayp + durasiPengembalian > 29) then
                    begin
                        dayk := dayp + durasiPengembalian - 29;
                        monthk := monthp + 1; yeark := yearp;
                    end else
                    begin
                        dayk := dayp + durasiPengembalian;
                        monthk := monthp; yeark := yearp;
                    end;
                end else
                begin
                    if (dayp + durasiPengembalian > 28) then
                    begin
                        dayk := dayp + durasiPengembalian - 28;
                        monthk := monthp + 1; yeark := yearp;
                    end else
                    begin
                        dayk := dayp + durasiPengembalian;
                        monthk := monthp; yeark := yearp;
                    end;
                end;
            end;
            temp.dd := dayk;
            temp.mm := monthk;
            temp.yyyy := yeark;
            tanggal_kembali := temp;
        end;

    function find_pinjam(recPinjamTemp : recpinjam; username: string; id_buku : string):integer;
        var
            i : longint;
            data_found : boolean;
        begin
            data_found := false;
            i := 1;
            while (i <= recPinjamTemp.Neff) and (not data_found) do
            begin
                if (username = recPinjamTemp.tab[i].username) and (id_buku = recPinjamTemp.tab[i].id_book) then
                begin
                    data_found := true;
                    find_pinjam := i;
                end;
                i := i + 1;
            end;
        end;

    procedure pinjam_buku(var recBukuTemp : recbuku; var recPinjamTemp : recpinjam);
        var
            id_buku, tanggal_pinjam : string;
            day, month, year : string;
            index_buku : integer;
        begin
            writeln('Masukkan id buku yang ingin dipinjam: ');
            readln(id_buku);
            writeln('Masukkan tanggal hari ini: ');
            readln(tanggal_pinjam);
            index_buku := find_index_buku(recBukuTemp, id_buku);
            if (recBukuTemp.tab[index_buku].jumlah > 0) then
            begin    
                recPinjamTemp.Neff := recPinjamTemp.Neff + 1;
                recPinjamTemp.tab[recPinjamTemp.Neff].username := current_user;
                recPinjamTemp.tab[recPinjamTemp.Neff].id_book := id_buku;
                day := copy(tanggal_pinjam, 1, 2);
                month := copy(tanggal_pinjam, 4, 2);
                year := copy(tanggal_pinjam, 7, 4);
                val(day, recPinjamTemp.tab[recPinjamTemp.Neff].tglpinjam.dd);
                val(month, recPinjamTemp.tab[recPinjamTemp.Neff].tglpinjam.mm);
                val(year, recPinjamTemp.tab[recPinjamTemp.Neff].tglpinjam.yyyy);
                recPinjamTemp.tab[recPinjamTemp.Neff].status := 'belum';
                recPinjamTemp.tab[recPinjamTemp.Neff].tglkembali := tanggal_kembali(tanggal_pinjam);

                recBukuTemp.tab[index_buku].jumlah := recBukuTemp.tab[index_buku].jumlah - 1;
                writeln('Buku berhasil dipinjam!');
                writeln('Tersisa ',recBukuTemp.tab[index_buku].jumlah, ' buku ',recBukuTemp.tab[index_buku].judul);
                writeln('Terima kasih sudah meminjam');
            end else
            begin
                writeln('Buku ',recBukuTemp.tab[index_buku].judul,' Sedang habis!');
                writeln('Coba lain kali.');
            end;
        end;

    function selisih_hari(tanggal_pinjam : tanggal; tanggal_kembali : tanggal) : integer;
        var
            tahun, bulan, hari : longint;
        begin
            tahun := (tanggal_kembali.yyyy - tanggal_pinjam.yyyy) * 365;
            bulan := (tanggal_kembali.mm - tanggal_pinjam.mm) * 30;
            hari := (tanggal_kembali.dd - tanggal_pinjam.dd);
            selisih_hari := tahun + bulan + hari;
        end;

    procedure kembalikan_buku(var recBukuTemp : recbuku; var recPinjamTemp : recpinjam; var recKembaliTemp : reckembali);
        var
            id_buku, tanggal_hari_ini: string;
            hariPinStr, hariKemStr, bulanPinStr, bulanKemStr, tahunPinStr, tahunKemStr : string;
            index_buku : integer;
            denda_dari_hari : longint;
            index_pinjam : integer;
            
        begin
            write('Masukkan id buku yang dikembalikan : ');
            readln(id_buku);
            writeln('Data peminjaman: ');
            writeln('Username : ',current_user);

            index_pinjam := find_pinjam(recPinjamTemp, current_user, id_buku);
            index_buku := find_index_buku(recBukuTemp, id_buku);
            writeln('Judul Buku : ', recBukuTemp.tab[index_buku].judul);
            
            if (recPinjamTemp.tab[index_pinjam].tglpinjam.mm < 10) then // Cek apakah bulan peminjaman kurang dari 10. Jika ya, tambahkan char '0' didepan
            begin
                str(recPinjamTemp.tab[index_pinjam].tglpinjam.mm, bulanPinStr);
                bulanPinStr := '0' + bulanPinStr;  
            end else
            begin
                str(recPinjamTemp.tab[index_pinjam].tglpinjam.mm, bulanPinStr);
            end;

            if (recPinjamTemp.tab[index_pinjam].tglkembali.mm < 10) then // Cek apakah bulan pengembalian kurang dari 10. Jika ya, tambahkan char '0' didepan
            begin
                str(recPinjamTemp.tab[index_pinjam].tglkembali.mm, bulanKemStr);
                bulanKemStr := '0' + bulanKemStr;  
            end else
            begin
                str(recPinjamTemp.tab[index_pinjam].tglkembali.mm, bulanKemStr);
            end;

            if (recPinjamTemp.tab[index_pinjam].tglpinjam.dd < 10) then // Cek apakah hari peminjaman kurang dari 10. Jika ya, tambahkan char '0' didepan
            begin
                str(recPinjamTemp.tab[index_pinjam].tglpinjam.dd, hariPinStr);
                hariPinStr := '0' + hariPinStr;
            end else
            begin
                str(recPinjamTemp.tab[index_pinjam].tglpinjam.dd, hariPinStr);
            end;
            str(recPinjamTemp.tab[index_pinjam].tglpinjam.dd, hariPinStr);
            str(recPinjamTemp.tab[index_pinjam].tglpinjam.yyyy, tahunPinStr);

            if (recPinjamTemp.tab[index_pinjam].tglkembali.dd < 10) then // Cek apakah hari pengembalian kurang dari 10. Jika ya, tambahkan char '0' didepan
            begin
                str(recPinjamTemp.tab[index_pinjam].tglkembali.dd, hariKemStr);
                hariKemStr := '0' + hariKemStr;
            end else
            begin
                str(recPinjamTemp.tab[index_pinjam].tglkembali.dd, hariKemStr);
            end;
            str(recPinjamTemp.tab[index_pinjam].tglpinjam.yyyy, tahunPinStr);
            str(recPinjamTemp.tab[index_pinjam].tglkembali.yyyy, tahunKemStr);
            
            writeln('Tanggal Peminjaman : ', hariPinStr,'/',bulanPinStr,'/',tahunPinStr);
            writeln('Tanggal Pengembalian : ', hariKemStr, '/',bulanKemStr,'/',tahunKemStr);
            write('Masukkan Tanggal hari ini : '); readln(tanggal_hari_ini);

            recPinjamTemp.tab[index_pinjam].status := 'sudah';
            recBukuTemp.tab[index_buku].jumlah := recBukuTemp.tab[index_buku].jumlah + 1;
            recKembaliTemp.Neff := recKembaliTemp.Neff + 1;
            recKembaliTemp.tab[recKembaliTemp.Neff].username := current_user;
            recKembaliTemp.tab[recKembaliTemp.Neff].id_book := id_buku;
            val(copy(tanggal_hari_ini,1,2), recKembaliTemp.tab[recKembaliTemp.Neff].tgl.dd);
            val(copy(tanggal_hari_ini,4,2), recKembaliTemp.tab[recKembaliTemp.Neff].tgl.mm);
            val(copy(tanggal_hari_ini,7,4), recKembaliTemp.tab[recKembaliTemp.Neff].tgl.yyyy);
            denda_dari_hari := selisih_hari(recPinjamTemp.tab[index_pinjam].tglkembali, recKembaliTemp.tab[recKembaliTemp.Neff].tgl) * 2000;

            if (denda_dari_hari > 0) then
            begin
                writeln('Anda terlambat mengembalikan buku.');
                writeln('Anda mendapatkan denda sebesar: ', denda_dari_hari)
            end else
            begin
                writeln('Terimakasih sudah meminjam.'); 
            end;
        end;

    procedure lihat_laporan(recHilangTemp : rechilang; recBukuTemp : recbuku);
        var
            i, j : integer;
            temp : string;
            indexBuku : longint;
            day, month, year : string;
            id_temp_1, id_temp_2 : longint;
        begin
            writeln('test');
            for i:= 1 to recHilangTemp.Neff do
            begin
                for j:= 1 to recHilangTemp.Neff -1 do
                begin
                    val(recHilangTemp.tab[j].id_book, id_temp_1);
                    val(recHilangTemp.tab[j+1].id_book, id_temp_2);
                    if (id_temp_1 > id_temp_2) then
                    begin
                        temp := recHilangTemp.tab[j].id_book;
                        recHilangTemp.tab[j].id_book := recHilangTemp.tab[j+1].id_book;
                        recHilangTemp.tab[j+1].id_book := temp;
                    end;
                end;
            end;

            for i:= 1 to recHilangTemp.Neff do
            begin
                indexBuku := find_index_buku(recBukuTemp, recHilangTemp.tab[i].id_book);
                str(recHilangTemp.tab[i].tgl.dd, day);
                str(recHilangTemp.tab[i].tgl.mm, month);
                str(recHilangTemp.tab[i].tgl.yyyy, year);
                writeln(recHilangTemp.tab[i].id_book, ' | ', recBukuTemp.tab[indexbuku].judul,' | ',day,'/',month,'/',year);
            end;
        end;
end.
end.

