/**********************************************************************
 名    称：SFImportRow
 目    的：导入数据行
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2019-03-22
 备    注：
**********************************************************************/
public with sharing class SFImportRow {

    // Excel中的数据，如：{"A":"张三","B":"2000-12-25"}
    public Map<String, String> RowData {GET; SET;}

    // 数据在Excel中的行号
    public Integer RowIndex {GET; SET;}

    // 做数据校验时是否有错误
    public Boolean IsError {GET; SET;}

    // 校验错误时的错误字段名称
    public String ErrorField {GET; SET;}

    // 校验错误时的错误信息
    public String ErrorMessage {GET; SET;}

    // 是否和现有数据存在重复
    public Boolean IsDuplicate {GET; SET;}

    // 数据重复时的字段名称
    public String DuplicateField {GET; SET;}

    // 重复类型
    public String DuplicateType {GET; SET;}

    // 与之重复的记录
    public Sobject DuplicationRecord {GET; SET;}

    // 与之重复的记录的ID
    public String SobjectId {GET; SET;}

    public SFImportRow(Integer rowIndex, Map<String, String> rowData) {
        this.RowData = rowData;
        this.RowIndex = rowIndex;
        this.IsError = false;
        this.ErrorField = '';
        this.ErrorMessage = '';
        this.IsDuplicate = false;
        this.DuplicateField = '';
        this.DuplicateType = '';
        this.DuplicationRecord = null;
        this.SobjectId = '';
    }

    public SFImportRow() {
        this.IsError = false;
        this.ErrorField = '';
        this.ErrorMessage = '';
        this.IsDuplicate = false;
        this.DuplicateField = '';
        this.DuplicateType = '';
        this.DuplicationRecord = null;
        this.SobjectId = '';
    }
}