format PE GUI 4.0
entry start
include 'win32ax.inc'


;������ ��� �������� ������, �������� � ��������� ������ ��� ������
section '.data' data readable
errmsg  db '������ ��������� ������',0
hlpmsg  db '��������� ������ ����������� � �������: microproject x',13,10
        db '��� |x|<=1 ',13,10
        db '��������: microproject 0.5',0

capt    db '���������� ����� ���������� ����',0
fmt1    db '%lg',0
fmt     db 'x = %lg',13,10
        db '������ �������: %lg',13,10
        db '����� ���������� ����: %lg',0
e       dd 0.0005
c1      dd 1.0


;���� - ������ � ����� ��������
section '.code' code readable executable
start:  ; ��������� ����� ���������
        call main               ;����� ������� main
        invoke ExitProcess,0    ;�����


;�������� ��������� ���������
;������� ��������� �����������, ��������� ������ �� ����������
main:
        push ebp                ;������ �������
        mov ebp,esp             ;�������� ����� �����
        sub esp,408h            ;�������� ��������� ����������
x       equ ebp-408h
s       equ ebp-400h            ;�������������� ������
        push ebx                ;���������� ���������
        push esi
        push edi
        stdcall [GetCommandLine]        ;��������� ��������� ������
        mov edi,eax             ;�������� ����� ��������� ������
        ccall [lstrlen],eax             ;�������� ����� ��������� ������
        mov ebx,eax
        cmp byte [edi],'"'      ;���� ������ ��������� � �������
        jz quotes               ;��������� �������
        mov al,' '              ;����� ��� ������������ ����� �������� ��������
        mov ecx,ebx
        repne scasb             ;���� ������ ��� ����� ������
        jmp fnd                 ;����������
quotes: mov al,'"'              ;���� ��� ���� �������
        mov ecx,ebx
        repne scasb             ;������
        repne scasb             ;� ������
fnd:    lea eax,[x]             ;�������� ����� ��������� � �����
        ccall [sscanf],edi,fmt1,eax     ;���������� �����
        test eax,eax    ;��������� ���������
        jg calc

;� ������ ������ ������ ����������� ��������������� �����������
er:     stdcall [MessageBox],0,hlpmsg,errmsg,0
        jmp ex          ;�����
;��������� ��, ��� �����
calc:   fld qword [x]   ;x
        fabs            ;|x|
        fcomp [c1]      ;���������� |x| � 1 (�� ������� |x| < 1)
        fstsw ax        ;��������� ����� ��������� � ��
        sahf            ;������� ah � ����� ����������
        ja er           ;���� |x|>1, ������ ������������ ��������
        fld [e]         ;e
        sub esp,8       ;�������� � ����� ����� ��� double
        fstp qword [esp];�������� � ���� double �����     
        fld qword [x]   ;x
        sub esp,8       ;�������� � ����� ����� ��� double
        fstp qword [esp];�������� � ���� double �����     
        call mysqrt     ;��������� mysqrt(x,e)
        add esp,16      ;������� ���������� ���������     
        
        sub esp,8               ;�������� �������� 
        fstp qword [esp]        ;������� ����� ����
        fld1                    ;1
        fadd qword [x]          ;1+x
        fsqrt                   ;���������� ������� �������� sqrt(1+x)
        sub esp,8               ;�������� �������� 
        fstp qword [esp]        ;������� ����� ����
        fld qword [x]           ;x
        sub esp,8               ;�������� �������� (x)
        fstp qword [esp]        ;������� ����� ����
        push fmt                ;������ ���������
        lea ebx,[s]             ;����� ������������ ���������
        push ebx
        call [sprintf]          ;������������ ���������
        add esp,32              ;��������� �����
        invoke MessageBox,0,ebx,capt,MB_OK ;������� ���������
ex:     pop edi                 ;������������ ��������
        pop esi
        pop ebx
        leave
        ret                     ;����� �� �������

;��������� ���������� sqrt(a) � ��������� epsilon
mysqrt:
        push ebp                ;������� ���� �����
        mov ebp,esp
        sub esp,20              ;�������� ��������� ����������
;��������� ����������
tmp     equ ebp-20
a       equ ebp-16              ;�������� �� ������� ����
p       equ ebp-8               ;�������� �� ���������� ����
        fld1                    ;1
        fstp qword [a]          ;a=1
        xor ecx,ecx             ;n=0
        fldz                    ;s=0
lp:     fld qword [a]           ;a
        fst qword [p]           ;p=a
        faddp st1,st            ;s=s+a
        fld qword [a]           ;a
        mov eax,1               
        sub eax,ecx
        sub eax,ecx             ;1-2*n
        mov [tmp],eax
        fimul dword [tmp]       ;a*(1-2*n)
        inc ecx                 ;n++
        lea eax,[ecx*2]         ;2n
        mov [tmp],eax
        fmul qword [ebp+8]      ;a*x
        fidiv dword [tmp]       ;a*x/(2n)
        fst qword [a]           ;��������� �
        fsub qword [p]          ;a-p
        fabs                    ;|a-p|
        fcomp qword [ebp+16]    ;�������� |a-p| � e
        fstsw ax        ;��������� ����� ��������� � ��
        sahf            ;������� ah � ����� ����������
        jae lp          ;���� |a-p| >= e, ���������� ����
        fadd qword [a]  ;��������� ��������� ���������
        leave                   ;������ �������
        ret

section '.idata' import data readable writeable
  library kernel,'KERNEL32.DLL',\
        msvcrt,'MSVCRT.DLL',\
        user32,'USER32.DLL'

  import kernel,\
         lstrlen,'lstrlenA',\
         GetCommandLine,'GetCommandLineA',\
         ExitProcess,'ExitProcess'

  import user32,\
        MessageBox,'MessageBoxA'

  import msvcrt,\
        sprintf,'sprintf',\
        sscanf,'sscanf',\
        printf, 'printf'

