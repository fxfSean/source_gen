
class AddOrderBody {
  String order_id;
  String goods_id;
  String iccid;
  String user_id;
  int business;

  AddOrderBody(this.order_id, this.goods_id, this.iccid, this.user_id, this.business);
}
