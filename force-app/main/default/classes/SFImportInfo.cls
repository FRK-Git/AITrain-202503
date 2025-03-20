/**********************************************************************
 名    称：SFImportDataInfo
 目    的：导入数据类
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2019-03-22
 备    注：
**********************************************************************/
public with sharing class SFImportInfo {

    // 在保存数据时的错误信息
    public String ErrorMessage {GET; SET;}

    // 成功的数据集合
    public List<SFImportRow> SucessList {GET; SET;}

    // 校验错误的数据
    public List<SFImportRow> ErrorList {GET; SET;}

    // 校验重复的数据
    public List<SFImportRow> DuplicateList {GET; SET;}

    // 可以保存的正确数据
    public Map<String, Map<Integer, Sobject>> SObjectMap {GET; SET;}

    public SFImportInfo() {
        this.ErrorMessage = '';
        this.SucessList = new List<SFImportRow>();
        this.ErrorList = new List<SFImportRow>(); 
        this.DuplicateList = new List<SFImportRow>(); 
        this.SObjectMap = new Map<String, Map<Integer, Sobject>>();
    }

    // 从正确的列表中移去
    public void removeFromSuccess(SFImportRow errorRow) {
        for (Integer index = 0; index < this.SucessList.size(); index++) {
            SFImportRow row = this.SucessList[index];
            if (row.RowIndex == errorRow.RowIndex) {
                this.SucessList.remove(index);
                break;
            }
        }
    }

    // 从正确的列表中移去
    public void removeFromSuccess(List<SFImportRow> errorRows) {
        for (SFImportRow errorRow : errorRows) {
            this.removeFromSuccess(errorRow);
        }
    }

    // 增加到正确列表
    public void addToSuccess(SFImportRow row) {
        this.SucessList.add(row);
    }

    // 增加到正确列表
    public void addToSuccess(List<SFImportRow> rows) {
        this.SucessList.addAll(rows);
    }

    // 增加到错误列表
    public void addToError(SFImportRow row) {
        this.ErrorList.add(row);
    }

    // 增加到错误列表
    public void addToError(List<SFImportRow> rows) {
        this.ErrorList.addAll(rows);
    }

    // 增加到重复列表
    public void addToDuplicate(SFImportRow row) {
        this.DuplicateList.add(row);
    }

    // 增加到重复列表
    public void addToDuplicate(List<SFImportRow> rows) {
        this.DuplicateList.addAll(rows);
    }

    // 增加要保存的数据集合
    public void addToSObject(Map<String, Map<Integer, SObject>> newSobjectMap) {
        this.SObjectMap.putAll(newSobjectMap);
    }
}