public class CaseInvestmentProduct {

	public class Status {
		public String code;
		public String description;
	}

	public Status status;
	public List<ListFundClass> listFundClass;
	public PercOfFundType percOfFundType;

	public class PercOfFundType {
		public String Balanced;
		public String ForeignEquity;
		public String ForeignFixedIncome;
		public String LocalEquity;
		public String LocalFixedIncome;
		public String Others;
	}

	public class ListFundCode {
		public String unitHolderNo;
		public String fundCode;
		public String fundNameTh;
		public String fundNameEn;
		public String fundNickNameTh;
		public String fundNickNameEn;
		public String fundShortName;
		public String unrealizedProfit;
		public String marketValue;
	}

	public class ListFundHouse {
		public String fundHouseCode;
		public List<ListFundCode> listFundCode;
	}

	public class ListFundClass {
		public String fundClassCode;
		public String fundClassNameEn;
		public String fundClassNameTh;
		public List<ListFundHouse> listFundHouse;
	}

	public Request query;

	public class Queries {
		public List<String> unitHolderNos;
	}

	public class Request {
		public Queries query;
		public String parseObjToJson(CaseInvestmentProduct.Request obj) {
			return (string) System.JSON.Serialize(obj);
		}
	}

	public static CaseInvestmentProduct parseJsonToObj(String json) {
		return (CaseInvestmentProduct) System.JSON.deserialize(json, CaseInvestmentProduct.class);
	}

	public static List<CaseInvestmentProduct> parseJsonToObjList(String json) {
		return (List<CaseInvestmentProduct>) System.JSON.deserialize(json, List<CaseInvestmentProduct>.class);
	}

	public static String validateResponseSuccess (List<CaseInvestmentProduct> lst) {
		String status;
		if (lst != null) {
			for (CaseInvestmentProduct mfObj : lst) {
				if (mfObj.status.code == '0000') {
					status = 'Success';
				} else {
					status = mfObj.status.code + ' : ' + mfObj.status.description;
					break;
				}
			}
		}

		return status;
	}

	public static List<CaseProductNumberService.CaseProductWrapper> getCustomerProductInvestmentList(List<CaseInvestmentProduct> productInvestmentList,
	        Map<string /*product code*/, RTLProductMasterDTO> onlyProductWithProductCode) {
		List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();
		Integer count = 1;

		if (productInvestmentList != null && productInvestmentList.size() > 0) {
			for (CaseInvestmentProduct productInvestment : productInvestmentList) {
				if (productInvestment.listFundClass != null && productInvestment.listFundClass.size() > 0 ) {
					for (ListFundClass listFundClass : productInvestment.listFundClass) {
						ListFundClass listFund = listFundClass;
						if (listFund.listFundHouse.size() > 0) {
							for (ListFundHouse listFundHouse : listFund.listFundHouse) {
								ListFundHouse listHouse = listFundHouse;
								if (listHouse.listFundCode.size() > 0) {

									for (ListFundCode listFundCode : listHouse.listFundCode) {

										ListFundCode prod = listFundCode;
										RTLProductMasterDTO prdMaster = onlyProductWithProductCode.get(prod.fundCode);
										CaseProductNumberService.CaseProductWrapper caseProd = new CaseProductNumberService.CaseProductWrapper();
										caseProd.rowNum = count;
										caseProd.apiAccountNumber = prod.unitHolderNo;
										caseProd.apiAccountNumberMarking = prod.unitHolderNo;

										caseProd.apiProductType = 'Investment';
										if (prdMaster != null) {
											//find product subgroup and name from product code
											caseProd.apiProductSubGroup = prdMaster.Product_Sub_group;
											caseProd.apiProductName =  prdMaster.Name;
											caseProd.apiSuffix = prdMaster.Name;//MF Name assign to suffix
										} else {
											caseProd.apiProductSubGroup = System.label.Customer_Product_Not_Found;
											caseProd.apiProductName =  System.label.Customer_Product_Not_Found;
											caseProd.apiSuffix = null;
										}

										returnList.add(caseProd);
										count++;
									}
								}
							}
						}
					}
				}
			}
		}

		//returnList.sort();

		return returnList;
	}

	public static List<CaseProductNumberService.CaseProductWrapper> getCustomerProductInvestmentListFormat (List<CaseInvestmentProduct> productInvestmentList,
	        Map<string /*product code*/, RTLProductMasterDTO> onlyProductWithProductCode, List<String> unitHolderNoslist) {
		List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();

		List<CaseProductNumberService.CaseProductWrapper> responseList = new List<CaseProductNumberService.CaseProductWrapper>();
		Set<String> listFundCode = new Set<String>();
		Set<String> nonlistFundCode = new Set<String>();
		try {
			if (productInvestmentList != null) {
				responseList = getCustomerProductInvestmentList(productInvestmentList, onlyProductWithProductCode);

				if (responseList.size() > 0) {

					Integer count = 1;

					//list fund code is found product
					for (CaseProductNumberService.CaseProductWrapper res : responseList) {
						returnList.add(res);
						listFundCode.add(res.apiAccountNumber);
						count++;

					}

					//list fund code is not found product
					nonlistFundCode.addAll(unitHolderNoslist);
					for (String unit : listFundCode) {
						nonlistFundCode.remove(unit);
					}

					for (String unitNonFound : nonlistFundCode) {
						CaseProductNumberService.CaseProductWrapper caseProd = new CaseProductNumberService.CaseProductWrapper(
						    count,
						    unitNonFound,
						    unitNonFound,
						    null,
						    'Investment',
						    null,
						    '<p style="color:red;">' + Label.INT_Investment_Record_Not_Found + '</p>');
						returnList.add(caseProd);
						count++;

					}



				} else {

					//response is successful but list fund code is null.
					Integer count = 1;
					for (String unitHolder : unitHolderNoslist) {
						CaseProductNumberService.CaseProductWrapper caseProd = new CaseProductNumberService.CaseProductWrapper(
						    count,
						    unitHolder,
						    unitHolder,
						    null,
						    'Investment',
						    null,
						    '<p style="color:red;">' + Label.INT_Investment_Record_Not_Found + '</p>');
						returnList.add(caseProd);
						count++;

					}
				}
			}
		} catch (Exception e) {
			system.debug(e);
		}

		return returnList;

	}




}