program utama;

uses
	tubes;

var
	datbuku : recbuku;
	datuser : recuser;
	datpinjam : recpinjam;
	datkembali : reckembali;
	dathilang : rechilang;
	keycase, keyadm, keyvis : string;
	fileuser, filebuku, filepinjam, filekembali, filehilang: string;
	loginstat : char;
	isExit : char;

begin
	// Load File
	write('Masukkan nama File Buku: ');
	readln(filebuku);
	write('Masukkan nama File User: ');
	readln(fileuser);
	write('Masukkan nama File Peminjaman: ');
	readln(filepinjam);
	write('Masukkan nama File Pengembalian: ');
	readln(filekembali);
	write('Masukkan nama File Buku Hilang: ');
	readln(filehilang);

	datbuku := parsingBuku(filebuku);
	datuser := parsingUser(fileuser);
	datpinjam := parsingPinjam(filepinjam);
	dathilang := parsingHilang(filehilang);
	datkembali := parsingKembali(filekembali);
	//------------------------------------------

	keycase := 'main';
	repeat
	case keycase of
	'login' : begin	//Log in
			loginstat := login(datuser);
			if (loginstat = 'A') then keycase := 'admin' //ke menu admin
			else if (loginstat = 'N') then keycase := 'visitor' //ke menu pengunjung
			else keycase := 'main'; //kembali ke main menu
		end;

	'save' : begin	// Save
			write('Masukkan nama File Buku: ');
			readln(filebuku);
			write('Masukkan nama File User: ');
			readln(fileuser);
			write('Masukkan nama File Peminjaman: ');
			readln(filepinjam);
			write('Masukkan nama File Pengembalian: ');
			readln(filekembali);
			write('Masukkan nama File Buku Hilang: ');
			readln(filehilang);

			savebuku(datbuku, filebuku);
			saveuser(datuser, fileuser);
			savepinjam(datpinjam, filepinjam);
			savekembali(datkembali, filekembali);
			savehilang(dathilang, filehilang);

			writeln('Data berhasil disimpan!');
			keycase := 'main';
		end;

	'exit' : begin
			write('Apakah anda mau melakukan penyimpanan file yang sudah dilakukan (Y/N) ? ');
			readln(isExit);
			if (isExit = 'Y') then
			begin
				write('Masukkan nama File Buku: ');
				readln(filebuku);
				write('Masukkan nama File User: ');
				readln(fileuser);
				write('Masukkan nama File Peminjaman: ');
				readln(filepinjam);
				write('Masukkan nama File Pengembalian: ');
				readln(filekembali);
				write('Masukkan nama File Buku Hilang: ');
				readln(filehilang);

				savebuku(datbuku, filebuku);
				saveuser(datuser, fileuser);
				savepinjam(datpinjam, filepinjam);
				savekembali(datkembali, filekembali);
				savehilang(dathilang, filehilang);

				writeln('Data berhasil disimpan!');
				writeln('Terima kasih sudah mengunjungi perpustakaan Wan Shi Tong');
			end else
			begin
				writeln('Terima kasih sudah mengunjungi perpustakaan Wan Shi Tong');
			end;
			keycase := 'quit'; // Exit
		end;

	'admin' : begin	//Menu Admin
			writeln('- register');
			writeln('- cari');
			writeln('- caritahunterbit');
			writeln('- lihat_laporan');
			writeln('- tambah_buku');
			writeln('- tambah_jumlah_buku');
			writeln('- riwayat');
			writeln('- statistik');
			writeln('- cari_anggota');
			writeln('- logout');
			readln(keyadm);
			case keyadm of
			'register' : begin
					Registrasi(datuser);
				end;
			'cari' : begin
					cariKategori(datbuku);
				end;
			'caritahunterbit' : begin
					cariTahunTerbit(datbuku);
				end;
			'lihat_laporan' : begin
					lihat_laporan(dathilang,datbuku);
				end;
			'tambah_buku' : begin
					tambahbuku(datbuku);
				end;
			'tambah_jumlah_buku' : begin
					tambahjumlahbuku(datbuku);
				end;
			'riwayat' : begin
					riwayat(datpinjam,datbuku);
				end;
			'statistik' : begin
					statistik(datuser,datbuku);
				end;
			'cari_anggota' : begin
					cari_anggota(datuser);
				end;
			'logout' : begin 
					keycase := 'main';
					current_user := '';
				end;
			end;
		end;

	'visitor' : begin
			writeln('- cari');
			writeln('- caritahunterbit');
			writeln('- pinjam_buku');
			writeln('- kembalikan_buku');
			writeln('- lapor_hilang');
			writeln('- logout');
			readln(keyvis);
			case keyvis of
			'cari' : begin
						cariKategori(datbuku);
					 end;
			'caritahunterbit' : begin
						cariTahunTerbit(datbuku);
					 end;
			'pinjam_buku' : begin
						pinjam_buku(datbuku, datpinjam);
					 end;
			'kembalikan_buku' : begin
						kembalikan_buku(datbuku, datpinjam, datkembali);
					 end;
			'lapor_hilang' : begin
						lapor_hilang(dathilang);
					 end;
			'logout' : begin
					 	keycase := 'main';
						current_user := '';
					 end;
			end;
		end;
	'main' : begin
			// Main Menu
			writeln('Selamat datang di perpustakaan Wan Shi Tong.');
			writeln('Pilih Menu yang Anda Inginkan.');
			writeln('login');
			writeln('save');
			writeln('exit');
			write('Pilihan Anda: ');
			readln(keycase);
		 end;
	end;
	until keycase = 'quit';
end.

