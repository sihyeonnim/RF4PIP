# RF4 PIP

[Release 1.0](https://github.com/sihyeonnim/RF4PIP/releases/tag/1.0)에서 `RF4PIP.exe`를 다운로드해 실행하면 RF4 본체를 자동으로 찾아 항상 위에 표시합니다. 크기를 조절할 수 있으며 X를 누르면 캡처를 정리하고 종료합니다. 게임 종료·재실행·최소화 복원 시 자동 재연결합니다. Steam 스트리밍은 제외합니다.

Windows 10 2004 이상이 필요합니다. HDR·독점 전체화면은 실제 게임 검증이 필요합니다.

.NET SDK 10.0.401로 프로젝트 폴더에서 빌드합니다:

```powershell
dotnet build RF4PIP.slnx
dotnet run --project src/RF4PIP/RF4PIP.csproj
dotnet publish src/RF4PIP/RF4PIP.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o artifacts/win-x64
```
