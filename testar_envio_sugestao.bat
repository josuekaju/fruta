@echo off
echo Enviando sugestão para o backend...

curl -X POST http://localhost:3000/api/sugestao ^
  -H "Content-Type: multipart/form-data" ^
  -F "imagem=@imagem.jpg" ^
  -F "latitude=-25.432" ^
  -F "longitude=-49.275" ^
  -F "comentario=Teste via BAT script"

pause
