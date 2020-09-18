#include "stdafx.h"
#include<iostream>
#include<vector>
using namespace std;

const int N = 8; //�˱���

//Ȩֵ����
vector<vector<int>> weight = {
	{ 0,14,25,27,10,11,24,16 },
	{ 14,0,18,15,27,28,16,14 },
	{ 25,18,0,19,14,19,16,10 },
	{ 27,15,19,0,22,23,15,14 },
	{ 10,27,14,22,0,14,13,20 },
	{ 11,28,19,23,14,0,15,18 },
	{ 24,16,16,15,13,15,0,27 },
	{ 16,14,10,14,20,18,27,0 }};

//��ʼ���洢����
vector<int> tempweight(N, 0);
vector<int> temppoint(N, -1);
// bestweight[i][j] ��¼͹�Ӷ���� {Vi, ..., Vj} �����ʷֵ�����Ȩֵ��
vector<vector<int>> bestweight(N, tempweight);
// bestpoint[i][j] ��¼�� Vi��Vj ���������ε��������� Vk ��
vector<vector<int>> bestpoint(N, temppoint);


//����Vi,Vk,Vj��ɵ������ε�Ȩ��֮��
int GetWeight(int i, int k, int j);

//�Ե����϶�̬�滮����n�������������ε�Ȩֵ֮��
int MinWeightTriangulation(int n);

//��ӡ͹�Ӷ���� {Vi, ..., Vj} �����������ʷֽ��
void Traceback(int i, int j);

int main() {
	cout << "͹�����Ȩ�ؾ���Ϊ��"  << endl;
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			cout << weight[i][j] << " ";
		}
		cout << endl;
	}
	cout << endl;
	cout <<"��̬�滮�㷨��������" << MinWeightTriangulation(N) << endl;
	cout << endl;
	cout << "���������ʷֽṹΪ��" << endl;
	Traceback(0, N - 1);
	cout << endl;

	cout << "bestPoint[i][j] ��¼�� Vi��Vj ���������ε��������� Vk Ϊ��"  << endl;
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			cout << bestpoint[i][j] << "\t";
		}
		cout << endl;
	}

	system("pause");
	return 0;
}


int GetWeight(int i, int k, int j)
{
	return weight[i][k] + weight[k][j] + weight[i][j];
}

int MinWeightTriangulation(int n)
{
	//�Զ�̬�滮�����ʼ��,�����ʼ����ʵ���Բ�����ǰ���Ѿ���ʼ������
	bestweight[n - 1][n - 1] = 0;//�����ʼ����©��[n-1][n-1]��
	for (int i = 0; i < n - 1; i++) {
		bestweight[i][i] = bestweight[i][i + 1] = 0;
	}

	//scale����������Ĺ�ģ��С������������{V0,V1,V2}�Ĺ�ģΪ2,������{V0,V1...V5}�Ĺ�ģΪ5
	for (int scale = 2; scale < n; scale++) {
		//�������������һ��Ϊn-scale-1������scale=2�����һ��������Ϊi=6,j+8,{V6,V7,V8}
		for (int i = 0; i < n - scale; i++) {
			// j ����ǰ�� Vi Ϊ����������ĺ�߽� Vj
			int j = i + scale;

			//�ȴ��� k = i+1�����������Ϊ����һ��ʼ�ĳ�ֵ����Աȣ�����Ҳ����ѡ���ʼ�����ֵ9999
			bestweight[i][j] = bestweight[i][i + 1] + bestweight[i + 1][j] + GetWeight(i, i + 1, j);
			bestpoint[i][j] = i + 1;

			//���˻�׼ֵ֮�󣬿��Կ�ʼѭ������k=i+2�����
			for (int k = i + 2; k < j; k++) {
				int temp = bestweight[i][k] + bestweight[k][j] + GetWeight(i, k, j);
				if (temp < bestweight[i][j]) {
					bestweight[i][j] = temp;
					bestpoint[i][j] = k;
				}
			}
		}
	}

	//�������Ͻǵ������ֵ��
	return bestweight[0][n - 1];
}

void Traceback(int i, int j)
{
	//ע����ݲ��ҵķ�������,i+1=j��ʾ�м�û���κε���ڣ�bestpoint[i][j]�ڲ���ֵΪ��ʼ��-1
	if (i+1 == j)
		return;
	Traceback(i,bestpoint[i][j]);
	cout << "V" << i << " -- V" << bestpoint[i][j] << " -- V" << j << " = " << GetWeight(i,bestpoint[i][j],j) << endl;
	Traceback(bestpoint[i][j],j);
}